


import 'dart:developer';
import 'dart:convert';
import 'package:delivery_mvp_app/CustomerScreen/home.screen.dart';
import 'package:delivery_mvp_app/data/Model/CancelOrderModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import '../data/Model/GetDeliveryByIdResModel.dart';
import 'Chat/chating.page.dart';

class PickupScreen extends StatefulWidget {
  final IO.Socket socket;
  final String deliveryId;
  final Map<String, dynamic> driver;
  final String? otp;
  final Map<String, dynamic>? pickup;
  final Map<String, dynamic>? dropoff;
  final dynamic amount;
  final Map<String, dynamic>? vehicleType;
  final String? status;
  final String? txId;
  const PickupScreen({
    super.key,
    required this.socket,
    required this.deliveryId,
    required this.driver,
    this.otp,
    this.pickup,
    this.dropoff,
    this.amount,
    this.vehicleType,
    this.status,
    this.txId,
  });

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}


class _PickupScreenState extends State<PickupScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = <Polyline>{};
  final TextEditingController _controller = TextEditingController();
  String receivedMessage = "";
  final List<Map<String, dynamic>> messages = [];
  Map<String, dynamic>? assignedDriver;
  bool isSocketConnected = false;
  late IO.Socket socket;
  List<LatLng> _routePoints = [];
  bool _routeFetched = false;
  String? toPickupDistance;
  String? toPickupDuration;
  String? pickupToDropDistance;
  String? pickupToDropDuration;
  String? totalDistance;
  String? totalDuration;
  late IO.Socket _socket;
  bool isLoadingData = true;
  String? error;  // Fetched data variables
  GetDeliveryByIdResModel? deliveryData;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _socket = widget.socket;
    _emitDriverArrivedAtPickup();
    _setupEventListeners();
    _fetchDeliveryData();
  }


  Future<void> _fetchDeliveryData() async {
    try {
      setState(() {
        isLoadingData = true;
        error = null;
      });
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.getDeliveryById(widget.deliveryId);
      if (mounted) {
        setState(() {
          deliveryData = response;
          isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoadingData = false;
        });
      }
    }
  }
  void _emitDriverArrivedAtPickup() {
    final payload = {
      "deliveryId": widget.deliveryId,
    };
    if (_socket.connected) {
      // Emit the event
      _socket.emit("delivery:status_update", payload);
      log("Emitted → $payload");
      // Listen for acknowledgment/response from server
      _socket.on("delivery:status_update", (data) {
        log("Status updated response: $data");
        // Handle success (e.g., update UI, stop loader, etc.)
        // Check if status is "completed"
        if (data['status'] == 'completed' ||data['status'] == 'cancelled_by_driver') {
          // Navigate to Home screen
          _navigateToHomeScreen();
        } else {
          // Handle other status updates
          _handleStatusUpdateSuccess(data);
        }
        _handleStatusUpdateSuccess(data);
      });
      // Optional: Listen for error
      _socket.on("delivery:status_error", (error) {
        log("Status update failed: $error");
        // Handle error
        // _handleStatusUpdateError(error);
      });

    } else {
      log("Socket not connected, retrying...");
      Future.delayed(const Duration(seconds: 2), _emitDriverArrivedAtPickup);
    }
  }
  void _navigateToHomeScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false, // Remove all previous routes
    );
  }
  void _setupEventListeners() {
    _socket.on("delivery:status_updated", (data) {
      log("Status confirmed by server: $data");
    });
    _socket.onConnect((_) {
      setState(() => isSocketConnected = true);
      _emitDriverArrivedAtPickup();
    });
    _socket.onDisconnect((_) => setState(() => isSocketConnected = false));
  }
  Future<void> _handleStatusUpdateSuccess(dynamic payload) async {
    log("📩 Booking Request Received: $payload");
  }
  Future<void> _fetchRoute() async {
    if (_currentLatLng == null) {
      print('Error: Current location is null');
      return;
    }
    if (widget.pickup == null) {
      print('Error: Pickup location is null');
      return;
    }
    const String apiKey = 'AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g';
    double totalDistKm = 0.0;
    int totalTimeMin = 0;
    List<LatLng> points1 = [];
    List<LatLng> points2 = [];
    // Fetch route to pickup
    String origin1 = '${_currentLatLng!.latitude},${_currentLatLng!.longitude}';
    final pickupLat = widget.pickup!['lat'] as double;
    final pickupLng = widget.pickup!['long'] as double;
    String dest1 = '$pickupLat,$pickupLng';
    Uri url1 = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': origin1,
      'destination': dest1,
      'key': apiKey,
    });
    try {
      final response1 = await http.get(url1);
      if (response1.statusCode == 200) {
        final data1 = json.decode(response1.body);
        if (data1['status'] == 'OK' && data1['routes'] != null && data1['routes'].isNotEmpty) {
          final String poly1 = data1['routes'][0]['overview_polyline']['points'];
          points1 = _decodePolyline(poly1);
          final leg1 = data1['routes'][0]['legs'][0];
          toPickupDistance = leg1['distance']['text'];
          toPickupDuration = leg1['duration']['text'];
          totalDistKm += (leg1['distance']['value'] as num) / 1000.0;
          totalTimeMin += (leg1['duration']['value'] as int) ~/ 60;
        } else {
          print('Directions API error for to pickup: ${data1['status']}');
        }
      } else {
        print('HTTP error for to pickup: ${response1.statusCode}');
      }
    } catch (e) {
      print('Exception fetching route to pickup: $e');
    }
    // Fetch route from pickup to drop (if drop location available)
    if (widget.dropoff != null) {
      final dropoffLat = widget.dropoff!['lat'] as double;
      final dropoffLng = widget.dropoff!['long'] as double;
      String origin2 = dest1;
      String dest2 = '$dropoffLat,$dropoffLng';
      Uri url2 = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
        'origin': origin2,
        'destination': dest2,
        'key': apiKey,
      });
      try {
        final response2 = await http.get(url2);
        if (response2.statusCode == 200) {
          final data2 = json.decode(response2.body);
          if (data2['status'] == 'OK' && data2['routes'] != null && data2['routes'].isNotEmpty) {
            final String poly2 = data2['routes'][0]['overview_polyline']['points'];
            points2 = _decodePolyline(poly2);
            final leg2 = data2['routes'][0]['legs'][0];
            pickupToDropDistance = leg2['distance']['text'];
            pickupToDropDuration = leg2['duration']['text'];
            totalDistKm += (leg2['distance']['value'] as num) / 1000.0;
            totalTimeMin += (leg2['duration']['value'] as int) ~/ 60;
          } else {
            print('Directions API error for pickup to drop: ${data2['status']}');
          }
        } else {
          print('HTTP error for pickup to drop: ${response2.statusCode}');
        }
      } catch (e) {
        print('Exception fetching route from pickup to drop: $e');
      }
    }
    // Update UI
    if (mounted) {
      setState(() {
        _polylines.clear();
        if (points1.isNotEmpty) {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('toPickup'),
              points: points1,
              color: Colors.green,
              width: 5,
            ),
          );
        }

        if (points2.isNotEmpty) {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('toDrop'),
              points: points2,
              color: Colors.blue,
              width: 5,
            ),
          );
        }

        totalDistance = '${totalDistKm.toStringAsFixed(1)} km';
        totalDuration = '${totalTimeMin.toStringAsFixed(0)} min';
        _routePoints = [...points1, ...points2];
      });

      // Animate camera to fit the route
      if (_mapController != null && _routePoints.isNotEmpty) {
        LatLngBounds bounds = _calculateBounds(_routePoints);
        _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      }

    }

    print('Route loaded: ${points1.length} points to pickup, ${points2.length} points to drop');

  }
  LatLngBounds _calculateBounds(List<LatLng> points) {
    if (points.isEmpty) {
      return LatLngBounds(
        southwest: _currentLatLng!,
        northeast: _currentLatLng!,
      );
    }

    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;


    for (LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }


    // Include pickup and drop if not in points
    final pickupLat = widget.pickup!['lat'] as double;
    final pickupLng = widget.pickup!['long'] as double;
    LatLng pickup = LatLng(pickupLat, pickupLng);
    if (pickup.latitude < minLat) minLat = pickup.latitude;
    if (pickup.latitude > maxLat) maxLat = pickup.latitude;
    if (pickup.longitude < minLng) minLng = pickup.longitude;
    if (pickup.longitude > maxLng) maxLng = pickup.longitude;


    if (widget.dropoff != null) {
      final dropoffLat = widget.dropoff!['lat'] as double;
      final dropoffLng = widget.dropoff!['long'] as double;
      LatLng drop = LatLng(dropoffLat, dropoffLng);
      if (drop.latitude < minLat) minLat = drop.latitude;
      if (drop.latitude > maxLat) maxLat = drop.latitude;
      if (drop.longitude < minLng) minLng = drop.longitude;
      if (drop.longitude > maxLng) maxLng = drop.longitude;
    }


    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

  }
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = <LatLng>[];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }
  void _addMarkers() {
    final markers = <Marker>{};
    if (_currentLatLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLatLng!,
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    // Pickup marker
    if (widget.pickup != null) {
      final pickupLat = widget.pickup!['lat'] as double;
      final pickupLng = widget.pickup!['long'] as double;
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(pickupLat, pickupLng),
          infoWindow: InfoWindow(title: widget.pickup!['name'] ?? 'Pickup'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        ),
      );
    }

    // Dropoff marker
    if (widget.dropoff != null) {
      final dropoffLat = widget.dropoff!['lat'] as double;
      final dropoffLng = widget.dropoff!['long'] as double;
      markers.add(
        Marker(
          markerId: const MarkerId('dropoff'),
          position: LatLng(dropoffLat, dropoffLng),
          infoWindow: InfoWindow(title: widget.dropoff!['name'] ?? 'Dropoff'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }
  void _sendMessage() {
    if (!isSocketConnected) {
      Fluttertoast.showToast(msg: "Socket not connected!");
      return;
    }
    if (_controller.text.trim().isEmpty) return;
    final message = _controller.text.trim();
    // Send to server (adjust event name if needed)
    socket.emit('send_message', {
      'message': message,
      'deliveryId': widget.deliveryId,
    });
    log('📤 Sent message: $message');

    setState(() {
      messages.add({'text': message, 'isMine': true});
    });

    _controller.clear();
  }
  void _showCancelBottomSheet() {
    final List<String> reasons = [
      'Driver not arrived on time',
      'Wrong pickup location',
      'Change of plans',
      'Better option available',
      'Other',
    ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return CancelBottomSheetContent(
          deliveryId: widget.txId.toString(),
          onCancel: () {
            Navigator.of(bottomSheetContext).pop();
          },
        );
      },
    );
  }
  @override
  void dispose() {
    socket.off('receive_message');
    socket.off('connect');
    socket.off('disconnect');
    socket.dispose();
    _controller.dispose();
    super.dispose();
  }
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied")),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Location permission permanently denied. Please enable it from settings.",
          ),
        ),
      );
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (!mounted) return;
    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
    });
    // Animate camera to current location after getting it
    if (_mapController != null && _currentLatLng != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentLatLng!, zoom: 15),
        ),
      );
    }

    _addMarkers(); // Re-add markers after location is set
    _fetchRoute(); // Fetch route after location is set
  }



  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    final driver = widget.driver;
    final vehicleType = widget.vehicleType ?? {};
    final driverName =
    "${driver['firstName'] ?? ''} ${driver['lastName'] ?? ''}"
        .trim()
        .isEmpty
        ? 'Unknown Driver'
        : "${driver['firstName'] ?? ''} ${driver['lastName'] ?? ''}";
    final driverPhone = driver['phone']?.toString() ?? 'N/A';
    final averageRating = driver['averageRating']?.toString() ?? '0';
    final pickupAddress =
        widget.pickup?['name']?.toString() ?? 'Unknown Pickup';
    final dropoffAddress =
        widget.dropoff?['name']?.toString() ?? 'Unknown Dropoff';
    final otp = widget.otp?.toString() ?? 'N/A';
    final amount = widget.amount?.toString() ?? '0';
    final status = widget.status?.toString() ?? 'N/A';
    final vehicleTypeName = vehicleType['name']?.toString() ?? 'N/A';
    final baseFare = vehicleType['baseFare']?.toString() ?? '0';
    final perKmRate = vehicleType['perKmRate']?.toString() ?? '0';
    final vehicalImage = vehicleType['image']?.toString().isNotEmpty == true
        ? vehicleType['image']
        : "https://media.istockphoto.com/id/1394758946/vector/no-image-raster-symbol-missing-available-icon-no-gallery-for-this-moment-placeholder.jpg?s=170667a&w=0&k=20&c=HMFTtins81JmJWSrFbjs-xNL_W0KXonnGwCWJo5IPp0=";
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
          }
        },
        child:
      Scaffold(
      body: _currentLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLatLng!,
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              if (_currentLatLng != null) {
                _addMarkers(); // Add markers once map is created
                _fetchRoute();
              }
            },
            markers: _markers,
            polylines: _polylines, // Add polylines to the map
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),

          if (toPickupDistance != null || pickupToDropDistance != null)
            Positioned(
              bottom: 70.h,
              left: 16.w,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (toPickupDistance != null)
                      Text(
                        'To Pickup: $toPickupDistance | $toPickupDuration',
                        style: GoogleFonts.inter(fontSize: 14.sp),
                      ),
                    if (pickupToDropDistance != null)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Text(
                          'To Drop: $pickupToDropDistance | $pickupToDropDuration',
                          style: GoogleFonts.inter(fontSize: 14.sp),
                        ),
                      ),
                    Text(
                      'Total: $totalDistance | $totalDuration',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.25,
            maxChildSize: 0.75,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 5.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),

                    /// DRIVER DETAILS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Your driver is arriving",
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: const Text(
                            "2 min", // TODO: Make dynamic based on ETA from payload if available
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    const Divider(),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(
                            // "assets/driver.png",
                            vehicalImage,
                          ),
                        ),
                        // Image.network(
                        //   vehicalImage,
                        //   width: 50.w,
                        //   height: 50.h,
                        // ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driverName.isEmpty
                                  ? 'Unknown Driver'
                                  : driverName,
                              style: GoogleFonts.inter(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            // TODO: Add car details if available in driver payload
                            Text(
                              vehicleTypeName,
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                color: Colors.grey[700],
                                letterSpacing: -1,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                Text(
                                  // "4.9",
                                  averageRating,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              driverPhone, // Use dynamic phone
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            // TODO: Add registration if available
                            Text(
                              "Phone Number",
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 15.h),
                    const Divider(),

                    /// PICKUP - DROP DETAILS
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.my_location,
                          color: Colors.green,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            pickupAddress,
                            style: GoogleFonts.inter(fontSize: 13.sp),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            dropoffAddress,
                            style: GoogleFonts.inter(fontSize: 13.sp),
                          ),
                        ),
                      ],
                    ),
                    // OTP Display if available
                    if (otp != null) ...[
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lock,
                              size: 16,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'OTP: ${otp}',
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 15.h),
                    Divider(),

                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tota Ammount",
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          // "₹120",
                          "₹$amount",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    const Divider(),
                    SizedBox(height: 20.h),
                    Text(
                      "Chat with Driver:",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // messages.isEmpty
                    //     ? const Center(child: Text("No messages yet"))
                    //     : SingleChildScrollView(
                    //   child: ListView.builder(
                    //     padding: EdgeInsets.all(16.w),
                    //     shrinkWrap: true,
                    //     physics:
                    //     const NeverScrollableScrollPhysics(),
                    //     itemCount: messages.length,
                    //     itemBuilder: (context, index) {
                    //       final msg = messages[index];
                    //       final isMine = msg['isMine'] as bool;
                    //       return Align(
                    //         alignment: isMine
                    //             ? Alignment.centerRight
                    //             : Alignment.centerLeft,
                    //         child: Container(
                    //           margin: EdgeInsets.symmetric(
                    //             vertical: 6.h,
                    //           ),
                    //           padding: EdgeInsets.symmetric(
                    //             horizontal: 14.w,
                    //             vertical: 10.h,
                    //           ),
                    //           constraints: BoxConstraints(
                    //             maxWidth: 250.w,
                    //           ),
                    //           decoration: BoxDecoration(
                    //             color: isMine
                    //                 ? Colors.blueAccent
                    //                 : Colors.grey.shade300,
                    //             borderRadius: BorderRadius.only(
                    //               topLeft: const Radius.circular(
                    //                 16,
                    //               ),
                    //               topRight: const Radius.circular(
                    //                 16,
                    //               ),
                    //               bottomLeft: Radius.circular(
                    //                 isMine ? 16 : 0,
                    //               ),
                    //               bottomRight: Radius.circular(
                    //                 isMine ? 0 : 16,
                    //               ),
                    //             ),
                    //           ),
                    //           child: Text(
                    //             msg['text'],
                    //             style: GoogleFonts.inter(
                    //               fontSize: 14.sp,
                    //               color: isMine
                    //                   ? Colors.white
                    //                   : Colors.black,
                    //             ),
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [

                        Expanded(
                          child: GestureDetector(
                            onTap:(){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                  ChatingPage(
                                    socket:  widget.socket,
                                    senderId:  deliveryData!.data!.customer??"",
                                    receiverId: deliveryData!.data!.deliveryBoy!.id??"",
                                    deliveryId: deliveryData!.data!.id??"",

                                  )
                              ));
                            },
                            child: Container(
                              margin: EdgeInsets.only(top: 15.h, bottom: 20.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEEDEF),
                                borderRadius: BorderRadius.circular(40.r),
                              ),
                              child: TextField(
                                enabled: false,
                                controller: _controller,
                                decoration: InputDecoration(
                                  hintText: "Send a message to your driver...",
                                  hintStyle: GoogleFonts.inter(fontSize: 12.sp),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 12.h,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(
                                      Icons.send,
                                      color: Colors.black,
                                    ),
                                    onPressed: _sendMessage,
                                  ),
                                ),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                          ),
                        ),

SizedBox(width: 20.w,),

                        actionButton("assets/SvgImage/calld.svg"),


                      ],
                    ),

                    SizedBox(height: 20.h),

                    /// BOTTOM BUTTONS
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                            _showCancelBottomSheet, // Updated to show bottom sheet

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            child: Text(
                              "Cancel Ride",
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Implement help logic
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            child: Text(
                              "Help",
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

        ],
      ),
    ));
  }
  Future<void> cancelOrderApi(CancelOrderModel body) async {
    try {
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.deliveryCancelledByUser(body);
      final message = response.data['message'] as String?;
      if (message != null) {
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e, st) {
      log("${e.toString()} / ${st.toString()}");
      Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
  Widget actionButton(String icon, ) {
    return Column(
      children: [
        Container(
          width: 45.w,
          height: 45.h,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFEEEDEF),
          ),
          child: Center(
            child: SvgPicture.asset(icon, width: 18.w, height: 18.h),
          ),
        ),
        SizedBox(height: 6.h),
        // Text(
        //   label,
        //   style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.black),
        // ),
      ],
    );
  }
}





class CancelBottomSheetContent extends StatefulWidget {
  final String deliveryId;
  final VoidCallback onCancel;
  const CancelBottomSheetContent({
    super.key,
    required this.deliveryId,
    required this.onCancel,
  });
  @override
  State<CancelBottomSheetContent> createState() =>
      _CancelBottomSheetContentState();
}
class _CancelBottomSheetContentState extends State<CancelBottomSheetContent> {

  final List<String> reasons = [
    'Driver not arrived on time',
    'Wrong pickup location',
    'Change of plans',
    'Better option available',
    'Other',
  ];

  int selectedIndex = 0; // Default to first option selected
  final TextEditingController _otherController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Why do you want to cancel?',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 20.h),
              // Radios as a column of RadioListTiles
              ...reasons.asMap().entries.map((entry) {
                final index = entry.key;
                final reason = entry.value;
                return RadioListTile<int>(
                  title: Text(
                    reason,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.black87,
                    ),
                  ),
                  value: index,
                  groupValue: selectedIndex,
                  onChanged: _isLoading
                      ? null
                      : (int? value) {
                    setState(() {
                      selectedIndex = value ?? -1;
                      if (value != reasons.length - 1) {
                        _otherController.clear();
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.redAccent,
                );
              }).toList(),
              // Conditional TextField for "Other"
              if (selectedIndex == reasons.length - 1) ...[
                SizedBox(height: 10.h),
                TextField(
                  controller: _otherController,
                  enabled: !_isLoading,
                  maxLines: 3, // Increased for better usability
                  decoration: InputDecoration(
                    hintText: 'Enter your reason...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Colors.redAccent),
                    ),
                    contentPadding: EdgeInsets.all(12.w),
                  ),
                ),
                SizedBox(height: 10.h),
              ],
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                        widget.onCancel();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                        if (selectedIndex == -1) {
                          Fluttertoast.showToast(
                            msg: 'Please select a reason',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                          return;
                        }

                        String reason;
                        if (selectedIndex == reasons.length - 1) {
                          reason = _otherController.text.trim();
                          if (reason.isEmpty) {
                            Fluttertoast.showToast(
                              msg: 'Please enter a reason for Other',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                            return;
                          }
                        } else {
                          reason = reasons[selectedIndex];
                        }

                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          await cancelOrderApiStatic(
                            widget.deliveryId,
                            reason,
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                      child: _isLoading
                          ? SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                          : Text(
                        'Submit',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> cancelOrderApiStatic(String txtId, String reason) async {
    try {
      final body = CancelOrderModel(txId: txtId, cancellationReason: reason);
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.deliveryCancelledByUser(body);

      if (response.code == 0) {
        Fluttertoast.showToast(
          msg: response.message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        if (mounted) {
          // Pop the bottom sheet first
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
        }
      } else {
        Fluttertoast.showToast(
          msg: response.message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
    catch (e, st) {
        log("${e.toString()} / ${st.toString()}");
        Fluttertoast.showToast(
        msg: e.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }


}