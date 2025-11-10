
/*


import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/pickup.screen.dart';
import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/bookInstantdeliveryBodyModel.dart';
import 'package:delivery_mvp_app/data/controller/getDistanceController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

import '../data/Model/GetNearByDriverResponseModel.dart';
import '../data/Model/NearByDriverModel.dart';

class SelectTripScreen extends ConsumerStatefulWidget {
  final IO.Socket? socket;
  final double pickupLat;
  final double pickupLon;
  final double dropLat;
  final double dropLon;
  SelectTripScreen(
      this.socket,
      this.pickupLat,
      this.pickupLon,
      this.dropLat,
      this.dropLon,
      {super.key,});
  @override
  ConsumerState<SelectTripScreen> createState() => _SelectTripScreenState();
  }
    var box = Hive.box("folder");
    var id = box.get("id");
   class _SelectTripScreenState extends ConsumerState<SelectTripScreen> {
  List<Map<String, dynamic>> selectTrip = [
    {
      "image": "assets/b.png",
      "name": "Delivery Go",
      "ammount": "₹170.71",
      "discount": "₹188.71",
    },
    {
      "image": "assets/t.png",
      "name": "Delivery Go",
      "ammount": "₹170.71",
      "discount": "₹188.71",
    },
    {
      "image": "assets/car.png",
      "name": "Delivery Premier",
      "ammount": "₹223.63",
      "discount": "₹188.71",
    },
  ];
  GoogleMapController? _mapController;
  LatLng? _currentLatlng;
  int selectIndex = 0;
  bool _routeFetched = false;
  bool isBooking = false;
  Map<String, dynamic>? assignedDriver;
  bool isSocketConnected = false;
  final List<Map<String, dynamic>> messages = [];
  IO.Socket? socket;
  Position? _currentPosition;
  String? currentAddress;
  StreamSubscription<Position>? _locationSubscription;
  String? userId;
  String? bookedTxtId;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];
  String? toPickupDistance;
  String? toPickupDuration;
  String? pickupToDropDistance;
  String? pickupToDropDuration;
  String? totalDistance;
  String? totalDuration;
  late double pickupLat, pickupLon, dropLat, dropLon;
  late GetNearByDriverResponse nearbyDrivers;
  bool isLoadingDrivers = false;
  @override
  void initState() {
    super.initState();
    socket=widget.socket;
    pickupLat = widget.pickupLat;
    pickupLon = widget.pickupLon;
    dropLat =widget.dropLat;
    dropLon = widget.dropLon;
    userId = box.get("id")?.toString(); // Safe cast
    if (userId == null) {
      log('❌ User ID missing from Hive!');
    } else {
      log('✅ User ID: $userId');
    }
    socket = widget.socket;               // <-- use the passed socket
    // No need to call _connectSocket() any more

    userId = box.get("id")?.toString();
    _getCurrentLocation();
    startLocationStream();                // <-- start streaming right away
    _setupEventListeners();               // <-- set up listeners
  }
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Please enable location service");
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: "Location permission denied");
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
        msg: "Location permission permanently denied. Enable from settings.",
      );
      return;
    }
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    safeSetState(() {
      _currentPosition = position;
      _currentLatlng = LatLng(position.latitude, position.longitude);
    });
    log('📍 Current Location: ${position.latitude}, ${position.longitude}');
    if (mounted && _mapController != null) {
      _addMarkers();
      _fetchRoute();
    }
  }
  // ---------------- SAFE SETSTATE ----------------
  void safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }
  // ---------------- UPDATE ADDRESS ----------------
  Future<void> _updateAddress() async {
    if (_currentPosition == null) return;
    try {
      final placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        safeSetState(() {
          currentAddress =
          "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
        });
      } else {
        safeSetState(() {
          currentAddress =
          "${_currentPosition!.latitude}, ${_currentPosition!.longitude}";
        });
      }
    } catch (e) {
      log('Error updating address: $e');
      safeSetState(() {
        currentAddress =
        "${_currentPosition!.latitude}, ${_currentPosition!.longitude}";
      });
    }
  }
  // ---------------- UPDATE USER LOCATION TO SOCKET ---------------- (with ack)
  void updateUserLocation(double lat, double lon) {
    if (socket != null && socket!.connected && userId != null) {
      socket!.emitWithAck(
        'user:location_update',
        {'userId': userId, 'lat': lat, 'lon': lon},
        ack: (data) {
          log('📤 Location ACK: $data'); // Server confirms receipt
        },
      );
      log('📤 Location sent → lat: $lat, lon: $lon, userId: $userId');
    } else {
      log('⚠️ Socket not connected or userId null!');
    }
  }
  // ---------------- LOCATION STREAM ----------------
  void startLocationStream() {
    _locationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10, // every 10 meters
          ),
        ).listen((Position position) async {
          updateUserLocation(position.latitude, position.longitude);
          _currentPosition = position;
          await _updateAddress();
          safeSetState(() {});
        });
  }
  // ---------------- SOCKET CONNECTION ----------------


  // ✅ Centralized method to set up event listeners (avoids duplicates)
  void _setupEventListeners() {
    socket!.on('receive_message', (data) {
      if (!mounted) return;
      log('📩 Message received: $data');
      final messageText = data is Map && data.containsKey('message')
          ? data['message']
          : data.toString();
      safeSetState(() {
        messages.add({'text': messageText, 'isMine': false});
      });
    });
  }
  // ---------------- DISPOSE ----------------
  @override
  void dispose() {
    // Stop location updates
    _locationSubscription?.cancel();
    _locationSubscription = null;
    // Dispose Google Map safely
    if (_mapController != null) {
      try {
        _mapController?.dispose();
      } catch (e) {
        log("Map dispose error: $e");
      }
      _mapController = null;
    }
    // Disconnect socket safely
    if (socket != null) {
      // _listenersSetup = false;  // Reset flag
      socket!.off('receive_message');
      socket!.clearListeners(); // ✅ removes all listeners
      socket!.disconnect();
      socket!.dispose(); // Better than close()
      socket = null;
    }
    super.dispose();
  }
  void _addMarkers() {
    _markers.clear(); // Clear previous markers to avoid duplicates
    if (_currentLatlng != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: _currentLatlng!,
          infoWindow: const InfoWindow(title: 'Current Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(pickupLat, pickupLon),
        infoWindow: const InfoWindow(title: 'Pickup Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    _markers.add(
      Marker(
        markerId: const MarkerId('drop'),
        position: LatLng(dropLat, dropLon),
        infoWindow: const InfoWindow(title: 'Drop Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        ),
      ),
    );
    safeSetState(() {});
  }
  Future<void> _fetchRoute() async {
    if (_currentLatlng == null) {
      print('Error: Current location is null');
      return;
    }

    const String apiKey = 'AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g';
    double totalDistKm = 0.0;
    int totalTimeMin = 0;
    List<LatLng> points1 = [];
    List<LatLng> points2 = [];

    // Fetch route to pickup
    String origin1 = '${_currentLatlng!.latitude},${_currentLatlng!.longitude}';
    String dest1 = '$pickupLat,$pickupLon';

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
    String origin2 = dest1;
    String dest2 = '$dropLat,$dropLon';
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

    // Update UI
    if (mounted) {

      safeSetState(() {
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
        southwest: _currentLatlng!,
        northeast: _currentLatlng!,
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
    LatLng pickup = LatLng(pickupLat, pickupLon);
    if (pickup.latitude < minLat) minLat = pickup.latitude;
    if (pickup.latitude > maxLat) maxLat = pickup.latitude;
    if (pickup.longitude < minLng) minLng = pickup.longitude;
    if (pickup.longitude > maxLng) maxLng = pickup.longitude;
    LatLng drop = LatLng(dropLat, dropLon);
    if (drop.latitude < minLat) minLat = drop.latitude;
    if (drop.latitude > maxLat) maxLat = drop.latitude;
    if (drop.longitude < minLng) minLng = drop.longitude;
    if (drop.longitude > maxLng) maxLng = drop.longitude;
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = <LatLng>[];
    int index = 0;
    final int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  void _addNearbyDriverMarkers() {
    if (nearbyDrivers.data == null || nearbyDrivers.data!.isEmpty) {
      log("No nearby drivers to show");
      return;
    }

    // Remove old driver markers only
    _markers.removeWhere((m) => m.markerId.value.startsWith('driver_'));

    for (int i = 0; i < nearbyDrivers.data!.length; i++) {
      final driver = nearbyDrivers.data![i];

      final coordinates = driver.currentLocation?.coordinates;
      if (coordinates == null || coordinates.length < 2) {
        log("Skipping driver ${driver.firstName}: invalid coordinates");
        continue;
      }

      final double lon = coordinates[0] is num ? coordinates[0].toDouble() : 0.0;
      final double lat = coordinates[1] is num ? coordinates[1].toDouble() : 0.0;

      if (lat == 0.0 || lon == 0.0) {
        continue;
      }

      final markerId = MarkerId('driver_$i');

      _markers.add(
        Marker(
          markerId: markerId,
          position: LatLng(lat, lon), // Note: LatLng(lat, lon) → latitude first
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
            title: driver.firstName ?? "Driver",
            snippet: "${driver.vehicleDetails ?? "Vehicle"} • ${driver.distance ?? "?"} km",
          ),
          onTap: () {
            Fluttertoast.showToast(
              msg: "${driver.firstName} (${driver.phone})",
            );
          },
        ),
      );
    }

    safeSetState(() {});
    log("Added ${nearbyDrivers.data!.length} driver markers on map");
  }

  @override
  Widget build(BuildContext context) {
    var box = Hive.box("folder");
    final distanceProviderState = ref.watch(getDistanceProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: distanceProviderState.when(
        data: (snp) {
          final name = snp.data[0].name;
          final phon = snp.data[0].mobNo;
          final pickupAddress = snp.data[0].origName;
          final dropAddress = snp.data[0].destName;
          return _currentLatlng == null  // Assuming _currentLatlng is defined; use consistent naming
              ? const Center(child: CircularProgressIndicator())
              : Stack(
            children: [

              // Full-screen map
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentLatlng!,
                  zoom: 15,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  if (_currentLatlng != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.newLatLng(_currentLatlng!),
                    );
                  }
                  // Add markers and fetch route if location is ready
                  if (_currentLatlng != null) {
                    _addMarkers();
                    _fetchRoute();
                  }
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: _markers,
                polylines: _polylines,
              ),
              // Back button overlay
              Positioned(
                left: 10.w,
                top: 40.h,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: const Color(0xFFFFFFFF),
                  shape: const CircleBorder(),
                  onPressed: () {
                    // Navigator.push(context, MaterialPageRoute(builder: (context)=>InstantDeliveryScreen()));
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 10.w),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xFF1D3557),
                    ),
                  ),
                ),
              ),
              // Distance info overlay
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
                initialChildSize: 0.47,  // Approximate: 400 / screen height (adjust based on device; ~0.47 for 850px screen)
                minChildSize: 0.47,  // Fixed min to match initial
                maxChildSize: 0.47,  // Fixed max to keep height constant at ~400 logical pixels
                builder: (context, scrollController) {
                  return Container(
                    height: 400.h,  // Explicit fixed height enforcement
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(  // Scrollable if content exceeds 400.h
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,  // Fit content within fixed height
                        children: [

                          // Vehicle selection horizontal list (fixed height container)
                          SizedBox(
                            height: 200.h,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: snp.data.length,
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                final isSelected = selectIndex == index;
                                return GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      selectIndex = index;
                                      isLoadingDrivers = true;
                                    });

                                    try {
                                      final selectedVehicle = snp.data[index];

                                      // API Body
                                      final body = NearByDriverModel(
                                        lat: widget.pickupLat,
                                        long: widget.pickupLon,
                                        vehicleId: selectedVehicle.vehicleTypeId, // या जो भी field server expect करता है
                                      );

                                      // API Call
                                      final drivers = await APIStateNetwork(callPrettyDio()).getNearByDriverList(body); // आपका service function

                                      setState(() {
                                        nearbyDrivers = drivers;
                                        isLoadingDrivers = false;
                                        _addNearbyDriverMarkers(); // YEH LINE ADD KARO
                                      });

                                      log("Nearby Drivers: ${drivers.data!.length} found for vehicle: ${selectedVehicle.name}");

                                      // Optional: Show toast
                                      Fluttertoast.showToast(msg: "${drivers.data!.length} drivers nearby");

                                    } catch (e) {
                                      setState(() {
                                        isLoadingDrivers = false;
                                      });
                                      Fluttertoast.showToast(msg: "No drivers found");
                                      log("Error fetching drivers: $e");
                                    }
                                  },
                             */
/*     onTap: () {


                                    setState(() {
                                      selectIndex = index;
                                    });


                                  },*//*

                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: isSelected ? 0.h : 10.h,
                                    ),
                                    width: 130.w,
                                    height: isSelected ? 180.h : 170.h,
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFFE5F0F1) : Colors.white,
                                      borderRadius: BorderRadius.circular(15.r),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.grey.shade400,
                                        width: isSelected ? 1.5.w : 1.w,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? Colors.black26
                                              : Colors.black12,
                                          blurRadius: isSelected ? 8 : 4,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 10),
                                        Center(
                                          child: Text(
                                            "In 2 min",
                                            style: GoogleFonts.inter(
                                              fontSize: isSelected ? 15.sp : 13.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 10),
                                          child: Center(
                                            child: AnimatedScale(
                                              duration: const Duration(milliseconds: 250),
                                              scale: isSelected ? 1.15 : 1.0,
                                              curve: Curves.easeOutBack,
                                              child: Image.network(
                                                snp.data[index].image,
                                                width: 116.w,
                                                height: 70.h,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, top: 10),
                                          child: Text(
                                            snp.data[index].name,
                                            style: GoogleFonts.inter(
                                              fontSize: isSelected ? 17.sp : 15.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Text(
                                            "₹${snp.data[index].price}",
                                            style: GoogleFonts.inter(
                                              fontSize: isSelected ? 16.sp : 14.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 10.h),

                          // Payment methods row
                          Container(
                            margin: EdgeInsets.only(left: 0.w, right: 0.w, top: 10.h),  // Adjusted margin
                            width: MediaQuery.of(context).size.width,
                            height: 50.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: Colors.grey, width: 1.w),  // Fixed strokeAlign -> width
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(children: [
                                  Image.asset(
                                      height: 20.h,
                                      width: 20.w,
                                      "assets/cash.png"),
                                  SizedBox(width: 10.w,),
                                  Text(
                                    "Cash",
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],),
                                Row(children: [
                                  Image.asset(
                                      height: 20.h,
                                      width: 20.w,
                                      "assets/promo.png"),
                                  SizedBox(width: 10.w,),
                                  Text(
                                    "Promo Code",
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],),

                                Row(children: [
                                  Image.asset(
                                      height: 20.h,
                                      width: 20.w,
                                      "assets/note.png"),
                                  SizedBox(width: 10.w,),
                                  Text(
                                    "Add Note",
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),

                                ],)


                                // methodPay("assets/SvgImage/cashes.svg"),
                                // methodPay("assets/SvgImage/addpromo.svg"),
                                // methodPay("assets/SvgImage/ed.svg"),
                              ],
                            ),
                          ),
                          SizedBox(height: 10.h),

                          // Book Now button
                          Padding(
                            padding: EdgeInsets.only(left: 0.w, right: 0.w),  // Adjusted for full width
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                backgroundColor: const Color(0xFF006970),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.r),
                                ),
                              ),
                              onPressed: isBooking
                                  ? null
                                  : () async {
                                setState(() => isBooking = true);
                                try {
                                  final selectedVehicle = snp.data[selectIndex];
                                  final body = BookInstantDeliveryBodyModel(
                                    vehicleTypeId: selectedVehicle.vehicleTypeId,
                                    price: double.parse(selectedVehicle.price).toInt(),
                                    isCopanCode: false,
                                    copanId: null.toString(),
                                    copanAmount: 0,
                                    coinAmount: 0,
                                    taxAmount: 18,
                                    userPayAmount: double.parse(selectedVehicle.price).toInt(),
                                    distance: selectedVehicle.distance,
                                    mobNo: phon,  // Dynamic from snp
                                    name: name,  // Dynamic from snp
                                    origName: pickupAddress,  // Dynamic from snp
                                    origLat:widget.pickupLat,
                                    // snp.data[0].origLat,  // Dynamic from snp
                                    origLon:widget.pickupLon,
                                    // snp.data[0].origLon,  // Dynamic from snp
                                    destName: dropAddress,  // Dynamic from snp
                                    destLat:widget.dropLat,
                                    // selectedVehicle.destLat,
                                    destLon:widget.dropLon,
                                    // selectedVehicle.destLon,
                                    picUpType: selectedVehicle.picUpType,
                                  );
                                  final service = APIStateNetwork(callPrettyDio());
                                  final response = await service.bookInstantDelivery(body);
                                  if (response.code == 0) {
                                    box.put("current_booking_txId", response.data!.txId);
                                    log('✅ Booking created — txId: ${response.data!.txId}');
                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => WaitingForDriverScreen(
                                          body: body,
                                          socket: socket!,  // Ensure socket is defined
                                          pickupLat: pickupLat,
                                          pickupLon: pickupLon,
                                          dropLat: dropLat,
                                          dropLon: dropLon,
                                        ),
                                        fullscreenDialog: true,
                                      ),
                                    );
                                    Fluttertoast.showToast(
                                      msg: "Delivery booked, waiting for driver...",
                                    );
                                    setState(() {
                                      isBooking = false;
                                    });
                                  } else {
                                    Fluttertoast.showToast(msg: response.message);
                                    setState(() {
                                      isBooking = false;
                                    });
                                  }
                                } catch (e, st) {
                                  setState(() {
                                    isBooking = false;
                                  });
                                  log("${e.toString()} / ${st.toString()}");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Booking failed: $e"),
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.only(
                                        left: 15.w,
                                        bottom: 15.h,
                                        right: 15.w,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15.r),
                                        side: BorderSide.none,
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              child: isBooking
                                  ? Center(
                                child: SizedBox(
                                  width: 30.w,
                                  height: 30.h,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.w,
                                  ),
                                ),
                              )
                                  : Text(
                                "Book Now",
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // Bottom padding
                        ],
                      ),
                    ),
                  );
                },
              ),


            ],
          );
        },
        error: (error, stackTrace) {
          log(stackTrace.toString());
          return Center(child: Text(error.toString()));
        },
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

}
   Widget methodPay(String image) {
     return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [SvgPicture.asset(image)],
  );
}

*/


import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;
import 'package:delivery_mvp_app/CustomerScreen/pickup.screen.dart';
import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/bookInstantdeliveryBodyModel.dart';
import 'package:delivery_mvp_app/data/controller/getDistanceController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

import '../data/Model/GetNearByDriverResponseModel.dart';
import '../data/Model/NearByDriverModel.dart';

class SelectTripScreen extends ConsumerStatefulWidget {
  final IO.Socket? socket;
  final double pickupLat;
  final double pickupLon;
  final double dropLat;
  final double dropLon;

  const SelectTripScreen(
      this.socket,
      this.pickupLat,
      this.pickupLon,
      this.dropLat,
      this.dropLon, {
        super.key,
      });

  @override
  ConsumerState<SelectTripScreen> createState() => _SelectTripScreenState();
}

class _SelectTripScreenState extends ConsumerState<SelectTripScreen> {
  final box = Hive.box("folder");

  GoogleMapController? _mapController;
  LatLng? _currentLatlng;
  Position? _currentPosition;
  StreamSubscription<Position>? _locationSubscription;
  String? userId;

  late double pickupLat, pickupLon, dropLat, dropLon;
  String? toPickupDistance, toPickupDuration;
  String? pickupToDropDistance, pickupToDropDuration;
  String? totalDistance, totalDuration;

  int selectIndex = 0;
  bool isBooking = false;
  bool isLoadingDrivers = false;
  IO.Socket? socket;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];

  late GetNearByDriverResponse nearbyDrivers;

  // Custom Icons

  late BitmapDescriptor driverCarIcon;
  late BitmapDescriptor driverBikeIcon;
  late BitmapDescriptor driverAutoIcon;
  late BitmapDescriptor driverTruckIcon;
  late BitmapDescriptor driverCycleIcon;
  bool _iconsLoaded = false;

  @override
  void initState() {
    super.initState();
    socket = widget.socket;
    pickupLat = widget.pickupLat;
    pickupLon = widget.pickupLon;
    dropLat = widget.dropLat;
    dropLon = widget.dropLon;

    userId = box.get("id")?.toString();
    log('User ID: $userId');

    _getCurrentLocation();
    startLocationStream();
    _setupEventListeners();
    _loadCustomIcons();
  }

  Future<void> _loadCustomIcons() async {
    try {
      driverCarIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(72, 72)),
        'assets/icons/car.png',
      );
      driverBikeIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(72, 72)),
        'assets/icons/b.png',
      );
      driverAutoIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(72, 72)),
        'assets/icons/t.png',
      );

      driverTruckIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(72, 72)),
        'assets/icons/truck.png',
      );

      driverCycleIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(72, 72)),
        'assets/icons/cycle.png',
      );

      _iconsLoaded = true;
      if (mounted) safeSetState(() {});
      log("Custom driver icons loaded");
    } catch (e) {
      log("Icon load error: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Enable location service");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: "Location denied permanently");
      return;
    }

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    safeSetState(() {
      _currentPosition = position;
      _currentLatlng = LatLng(position.latitude, position.longitude);
    });

    if (mounted && _mapController != null) {
      _addMarkers();
      _fetchRoute();
      _fitAllMarkersAndDrivers();
    }
  }

  void safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  void startLocationStream() {
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((position) {
      updateUserLocation(position.latitude, position.longitude);
      _currentPosition = position;
    });
  }

  void updateUserLocation(double lat, double lon) {
    if (socket?.connected == true && userId != null) {
      socket!.emitWithAck('user:location_update', {'userId': userId, 'lat': lat, 'lon': lon});
    }
  }

  void _setupEventListeners() {
    socket?.on('receive_message', (data) => log('Message: $data'));
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController?.dispose();
    socket?.clearListeners();
    socket?.disconnect();
    super.dispose();
  }

  void _addMarkers() {
    _markers.clear();
    if (_currentLatlng != null) {
      _markers.add(Marker(
        markerId: const MarkerId('current'),
        position: _currentLatlng!,
        infoWindow: const InfoWindow(title: 'You'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }
    _markers.add(Marker(
      markerId: const MarkerId('pickup'),
      position: LatLng(pickupLat, pickupLon),
      infoWindow: const InfoWindow(title: 'Pickup'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
    _markers.add(Marker(
      markerId: const MarkerId('drop'),
      position: LatLng(dropLat, dropLon),
      infoWindow: const InfoWindow(title: 'Drop'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    ));
    safeSetState(() {});
  }

  // void _addNearbyDriverMarkers() {
  //   if (nearbyDrivers.data == null || nearbyDrivers.data!.isEmpty || !_iconsLoaded) {
  //     log("No drivers or icons not ready");
  //     return;
  //   }
  //
  //   _markers.removeWhere((m) => m.markerId.value.startsWith('driver_'));
  //
  //   for (int i = 0; i < nearbyDrivers.data!.length; i++) {
  //     final driver = nearbyDrivers.data![i];
  //
  //     final coords = driver.currentLocation?.coordinates;
  //     if (coords == null || coords.length < 2) continue;
  //
  //     final double lon = coords[0];
  //     final double lat = coords[1];
  //     if (lat == 0.0 || lon == 0.0) continue;
  //
  //     final String model = (driver.vehicleDetails?.isNotEmpty == true)
  //         ? (driver.vehicleDetails![0].model ?? "").toLowerCase()
  //         : "";
  //
  //     BitmapDescriptor icon;
  //     if (model.contains("bike") || model.contains("motorcycle") || model.contains("activa") || model.contains("scooter")) {
  //       icon = driverBikeIcon;
  //     } else if (model.contains("car") || model.contains("sedan") || model.contains("innova") || model.contains("ertiga")) {
  //       icon = driverCarIcon;
  //     } else {
  //       icon = driverScooterIcon;
  //     }
  //
  //     _markers.add(Marker(
  //       markerId: MarkerId('driver_$i'),
  //       position: LatLng(lat, lon),
  //       icon: icon,
  //       infoWindow: InfoWindow(
  //         title: "${driver.firstName ?? "Driver"} ${driver.lastName ?? ""}",
  //         snippet: "${driver.vehicleDetails?[0].model ?? "Vehicle"} • ${driver.distance?.toStringAsFixed(1) ?? "?"} km",
  //       ),
  //       onTap: () {
  //         Fluttertoast.showToast(
  //           msg: "${driver.firstName} • ${driver.phone} • ${driver.vehicleDetails?[0].model}",
  //           toastLength: Toast.LENGTH_LONG,
  //         );
  //       },
  //     ));
  //   }
  //
  //   safeSetState(() {});
  //   _fitAllMarkersAndDrivers();
  //   log("Added ${nearbyDrivers.data!.length} drivers with custom icons");
  // }
  // void _addNearbyDriverMarkers() {
  //   if (nearbyDrivers.data == null || nearbyDrivers.data!.isEmpty || !_iconsLoaded) {
  //     log("No drivers to show or icons not loaded");
  //     return;
  //   }
  //
  //   // ALWAYS clear old drivers first
  //   _markers.removeWhere((m) => m.markerId.value.startsWith('driver_'));
  //
  //   for (int i = 0; i < nearbyDrivers.data!.length; i++) {
  //     // ... same code as before ...
  //     final driver = nearbyDrivers.data![i];
  //     //
  //         final coords = driver.currentLocation?.coordinates;
  //         if (coords == null || coords.length < 2) continue;
  //
  //         final double lon = coords[0];
  //         final double lat = coords[1];
  //         if (lat == 0.0 || lon == 0.0) continue;
  //
  //         final String model = (driver.vehicleDetails?.isNotEmpty == true)
  //             ? (driver.vehicleDetails![0].model ?? "").toLowerCase()
  //             : "";
  //
  //         BitmapDescriptor icon;
  //         if (model.contains("bike") || model.contains("motorcycle") || model.contains("activa") || model.contains("scooter")) {
  //           icon = driverBikeIcon;
  //         } else if (model.contains("car") || model.contains("sedan") || model.contains("innova") || model.contains("ertiga")) {
  //           icon = driverCarIcon;
  //         } else {
  //           icon = driverScooterIcon;
  //         }
  //
  //         _markers.add(Marker(
  //           markerId: MarkerId('driver_$i'),
  //           position: LatLng(lat, lon),
  //           icon: icon,
  //           infoWindow: InfoWindow(
  //             title: "${driver.firstName ?? "Driver"} ${driver.lastName ?? ""}",
  //             snippet: "${driver.vehicleDetails?[0].model ?? "Vehicle"} • ${driver.distance?.toStringAsFixed(1) ?? "?"} km",
  //           ),
  //           onTap: () {
  //             Fluttertoast.showToast(
  //               msg: "${driver.firstName} • ${driver.phone} • ${driver.vehicleDetails?[0].model}",
  //               toastLength: Toast.LENGTH_LONG,
  //             );
  //           },
  //         ));
  //   }
  //
  //   safeSetState(() {});
  //   _fitAllMarkersAndDrivers();
  // }


  // void _addNearbyDriverMarkers() {
  //   if (nearbyDrivers.data == null || nearbyDrivers.data!.isEmpty || !_iconsLoaded) {
  //     log("No drivers or icons not loaded");
  //     return;
  //   }
  //
  //   // CLEAR OLD DRIVERS
  //   _markers.removeWhere((m) => m.markerId.value.startsWith('driver_'));
  //
  //   for (int i = 0; i < nearbyDrivers.data!.length; i++) {
  //     final driver = nearbyDrivers.data![i];
  //
  //     final coords = driver.currentLocation?.coordinates;
  //     if (coords == null || coords.length < 2) continue;
  //
  //     final double lon = coords[0];
  //     final double lat = coords[1];
  //     if (lat == 0.0 || lon == 0.0) continue;
  //
  //     // UNIQUE ID USING DRIVER'S _id (NEVER REPEATS)
  //     final String uniqueId = 'driver_${driver.id ?? i}_${DateTime.now().millisecondsSinceEpoch}';
  //     final markerId = MarkerId(uniqueId);
  //
  //     final String model = (driver.vehicleDetails?.isNotEmpty == true)
  //         ? (driver.vehicleDetails![0].model ?? "").toLowerCase()
  //         : "";
  //
  //     BitmapDescriptor icon;
  //     if (model.contains("bike") || model.contains("yamaha") || model.contains("activa")) {
  //       icon = driverBikeIcon;
  //     } else if (model.contains("car") || model.contains("sedan") || model.contains("innova")) {
  //       icon = driverCarIcon;
  //     } else if (model.contains("truck") || model.contains("tata") || model.contains("eicher")) {
  //       icon = driverScooterIcon; // Ya truck icon bana lo
  //     } else {
  //       icon = driverBikeIcon;
  //     }
  //
  //     // ADD SMALL OFFSET SO MULTIPLE DRIVERS AT SAME LOCATION ARE VISIBLE
  //     final double offsetLat = lat + (i * 0.00003); // 3 meter offset
  //     final double offsetLon = lon + (i * 0.00003);
  //
  //     _markers.add(Marker(
  //       markerId: markerId,
  //       position: LatLng(offsetLat, offsetLon), // Offset so all show
  //       icon: icon,
  //       infoWindow: InfoWindow(
  //         title: "${driver.firstName} ${driver.lastName}",
  //         snippet: "${driver.vehicleDetails?[0].model} • ${(driver.distance! / 1000).toStringAsFixed(1)} km",
  //       ),
  //       onTap: () {
  //         Fluttertoast.showToast(
  //           msg: "${driver.firstName} • ${driver.phone} • ${driver.vehicleDetails?[0].model}",
  //           toastLength: Toast.LENGTH_LONG,
  //         );
  //       },
  //     ));
  //   }
  //
  //   safeSetState(() {});
  //   _fitAllMarkersAndDrivers();
  //   log("Added ${nearbyDrivers.data!.length} drivers (with offset for visibility)");
  // }

  void _addNearbyDriverMarkers() {
    if (nearbyDrivers.data == null || nearbyDrivers.data!.isEmpty || !_iconsLoaded) {
      log("No drivers or icons not loaded");
      return;
    }

    // CLEAR OLD DRIVERS
    _markers.removeWhere((m) => m.markerId.value.startsWith('driver_'));

    final int totalDrivers = nearbyDrivers.data!.length;
    log("Adding $totalDrivers drivers to map");

    for (int i = 0; i < totalDrivers; i++) {
      final driver = nearbyDrivers.data![i];
      final coords = driver.currentLocation?.coordinates;
      if (coords == null || coords.length < 2) continue;

      double baseLat = coords[1];
      double baseLon = coords[0];

      // UNIQUE ID using driver _id
      final String markerId = 'driver_${driver.id ?? i}_${i}';

      // APPLY OFFSET IN A CIRCLE AROUND THE POINT
      final double angle = (i * 137.508); // Golden angle for even spread
      final double radius = 0.00008; // ~8-10 meters
      final double offsetLat = radius * cos(angle * pi / 180);
      final double offsetLon = radius * cos(angle * pi / 180) / cos(baseLat * pi / 180);

      final double finalLat = baseLat + offsetLat;
      final double finalLon = baseLon + offsetLon;

      final String model = (driver.vehicleDetails?.isNotEmpty == true)
          ? (driver.vehicleDetails![0].model ?? "").toLowerCase()
          : "bike";

      BitmapDescriptor icon;
      if (model.contains("Truck") ) {

        icon = driverTruckIcon; // Ya truck icon bana lo
      } else if (model.contains("Car") ) {
        icon = driverCarIcon;

      }

      else if (model.contains("Bike")){
        icon = driverBikeIcon;
      }

      else if(model.contains("Auto")){
        icon = driverAutoIcon;
      } else{
        icon = driverAutoIcon;
      }
      _markers.add(Marker(
        markerId: MarkerId(markerId),
        position: LatLng(finalLat, finalLon),
        icon: icon,
        anchor: const Offset(0.5, 0.5), // Center of icon
        zIndex: i.toDouble(), // Higher index on top
        infoWindow: InfoWindow(
          title: "${driver.firstName} ${driver.lastName}",
          snippet: "${driver.vehicleDetails?[0].model} • ${(driver.distance! / 1000).toStringAsFixed(1)} km",
        ),
        onTap: () {
          Fluttertoast.showToast(
            msg: "${driver.firstName} • ${driver.phone}",
            toastLength: Toast.LENGTH_LONG,
          );
        },
      ));
    }

    safeSetState(() {});
    _fitAllMarkersAndDrivers();
    log("Successfully added $totalDrivers drivers with circular offset");
  }

  void _fitAllMarkersAndDrivers() {
    if (_markers.isEmpty || _mapController == null) return;
    final positions = _markers.map((m) => m.position).toList();
    if (positions.length == 1) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(positions[0], 14));
      return;
    }
    final bounds = _calculateBounds(positions);
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  Future<void> _fetchRoute() async {
    if (_currentLatlng == null) return;

    const apiKey = 'AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g';
    double totalDistKm = 0.0;
    int totalTimeMin = 0;
    List<LatLng> points1 = [], points2 = [];

    // Route 1: Current → Pickup
    final url1 = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': '${_currentLatlng!.latitude},${_currentLatlng!.longitude}',
      'destination': '$pickupLat,$pickupLon',
      'key': apiKey,
    });

    try {
      final res = await http.get(url1);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['status'] == 'OK') {
          final poly = data['routes'][0]['overview_polyline']['points'];
          points1 = _decodePolyline(poly);
          final leg = data['routes'][0]['legs'][0];
          toPickupDistance = leg['distance']['text'];
          toPickupDuration = leg['duration']['text'];
          totalDistKm += (leg['distance']['value'] as num) / 1000;
          totalTimeMin += (leg['duration']['value'] as int) ~/ 60;
        }
      }
    } catch (e) { log("Route1 error: $e"); }

    // Route 2: Pickup → Drop
    final url2 = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': '$pickupLat,$pickupLon',
      'destination': '$dropLat,$dropLon',
      'key': apiKey,
    });

    try {
      final res = await http.get(url2);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['status'] == 'OK') {
          final poly = data['routes'][0]['overview_polyline']['points'];
          points2 = _decodePolyline(poly);
          final leg = data['routes'][0]['legs'][0];
          pickupToDropDistance = leg['distance']['text'];
          pickupToDropDuration = leg['duration']['text'];
          totalDistKm += (leg['distance']['value'] as num) / 1000;
          totalTimeMin += (leg['duration']['value'] as int) ~/ 60;
        }
      }
    } catch (e) { log("Route2 error: $e"); }

    safeSetState(() {
      _polylines.clear();
      if (points1.isNotEmpty) {
        _polylines.add(Polyline(polylineId: const PolylineId('toPickup'), points: points1, color: Colors.green, width: 5));
      }
      if (points2.isNotEmpty) {
        _polylines.add(Polyline(polylineId: const PolylineId('toDrop'), points: points2, color: Colors.blue, width: 5));
      }
      totalDistance = '${totalDistKm.toStringAsFixed(1)} km';
      totalDuration = '$totalTimeMin min';
      _routePoints = [...points1, ...points2];
    });

    if (_mapController != null && _routePoints.isNotEmpty) {
      _fitAllMarkersAndDrivers();
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
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

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points[0].latitude, maxLat = points[0].latitude;
    double minLng = points[0].longitude, maxLng = points[0].longitude;
    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
  }

  @override
  Widget build(BuildContext context) {
    final distanceProviderState = ref.watch(getDistanceProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: distanceProviderState.when(
        data: (snp) {
          final name = snp.data[0].name;
          final phon = snp.data[0].mobNo;
          final pickupAddress = snp.data[0].origName;
          final dropAddress = snp.data[0].destName;

          return _currentLatlng == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(target: _currentLatlng!, zoom: 15),
                onMapCreated: (controller) {
                  _mapController = controller;
                  _addMarkers();
                  _fetchRoute();
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: _markers,
                polylines: _polylines,
              ),

              Positioned(
                left: 10.w, top: 40.h,
                child: FloatingActionButton(
                  mini: true, backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, color: Color(0xFF1D3557)),
                ),
              ),

              if (totalDistance != null)
                Positioned(
                  bottom: 70.h, left: 16.w, right: 16.w,
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (toPickupDistance != null)
                          Text('To Pickup: $toPickupDistance | $toPickupDuration', style: GoogleFonts.inter(fontSize: 14.sp)),
                        if (pickupToDropDistance != null)
                          Text('Delivery: $pickupToDropDistance | $pickupToDropDuration', style: GoogleFonts.inter(fontSize: 14.sp)),
                        Text('Total: $totalDistance | $totalDuration', style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),

              DraggableScrollableSheet(
                initialChildSize: 0.47,
                minChildSize: 0.47,
                maxChildSize: 0.47,
                builder: (context, scrollController) {
                  return Container(
                    height: 400.h,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: snp.data.length,
                              itemBuilder: (context, index) {
                                final isSelected = selectIndex == index;
                                return GestureDetector(
                                  // onTap: () async {
                                  //   setState(() {
                                  //     selectIndex = index;
                                  //     isLoadingDrivers = true;
                                  //   });
                                  //
                                  //   try {
                                  //     final selectedVehicle = snp.data[index];
                                  //     final body = NearByDriverModel(
                                  //       lat: widget.pickupLat,
                                  //       long: widget.pickupLon,
                                  //       vehicleId: selectedVehicle.vehicleTypeId,
                                  //     );
                                  //
                                  //     final drivers = await APIStateNetwork(callPrettyDio()).getNearByDriverList(body);
                                  //
                                  //     setState(() {
                                  //       nearbyDrivers = drivers;
                                  //       isLoadingDrivers = false;
                                  //       _addNearbyDriverMarkers();
                                  //     });
                                  //
                                  //     Fluttertoast.showToast(msg: "${drivers.data!.length} drivers nearby");
                                  //   } catch (e) {
                                  //     setState(() => isLoadingDrivers = false);
                                  //     Fluttertoast.showToast(msg: "No drivers found");
                                  //   }
                                  // },

                                  onTap: () async {
                                    setState(() {
                                      selectIndex = index;
                                      isLoadingDrivers = true;

                                      // PURANE DRIVERS KO MAP SE HATAAO
                                      _markers.removeWhere((m) => m.markerId.value.startsWith('driver_'));
                                      safeSetState(() {}); // Map update karo
                                    });

                                    try {
                                      final selectedVehicle = snp.data[index];
                                      final body = NearByDriverModel(
                                        lat: widget.pickupLat,
                                        long: widget.pickupLon,
                                        vehicleId: selectedVehicle.vehicleTypeId,
                                      );

                                      final drivers = await APIStateNetwork(callPrettyDio()).getNearByDriverList(body);

                                      setState(() {
                                        nearbyDrivers = drivers;
                                        isLoadingDrivers = false;

                                        // Agar koi driver nahi mila → markers already clear hain
                                        // Agar mile → naye add honge
                                        if (drivers.data != null && drivers.data!.isNotEmpty) {
                                          _addNearbyDriverMarkers();
                                        } else {
                                          log("No drivers found for this vehicle");
                                          Fluttertoast.showToast(msg: "No drivers available");
                                          // Map already clear from above
                                        }
                                      });

                                    } catch (e) {
                                      setState(() => isLoadingDrivers = false);
                                      Fluttertoast.showToast(msg: "Error fetching drivers");
                                      log("Error: $e");
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: isSelected ? 0 : 10.h),
                                    width: 130.w,
                                    height: isSelected ? 180.h : 170.h,
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(0xFFE5F0F1) : Colors.white,
                                      borderRadius: BorderRadius.circular(15.r),
                                      border: Border.all(
                                        color: isSelected ? Colors.black : Colors.grey.shade400,
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected ? Colors.black26 : Colors.black12,
                                          blurRadius: isSelected ? 8 : 4,
                                          offset: const Offset(0, 4),
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 10),
                                        Text("In 2 min", style: GoogleFonts.inter(fontSize: isSelected ? 15.sp : 13.sp, fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 10),
                                        AnimatedScale(
                                          scale: isSelected ? 1.15 : 1.0,
                                          duration: const Duration(milliseconds: 250),
                                          child: Image.network(snp.data[index].image, width: 116.w, height: 70.h, fit: BoxFit.contain),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, top: 10),
                                          child: Text(snp.data[index].name, style: GoogleFonts.inter(fontSize: isSelected ? 17.sp : 15.sp, fontWeight: FontWeight.w600)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Text("₹${snp.data[index].price}", style: GoogleFonts.inter(fontSize: isSelected ? 16.sp : 14.sp)),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          SizedBox(height: 10.h),

                          // Payment Methods
                          Container(
                            margin: EdgeInsets.only(top: 10.h),
                            width: double.infinity,
                            height: 50.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: Colors.grey, width: 1.w),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(children: [Image.asset("assets/cash.png", height: 20.h, width: 20.w), SizedBox(width: 10.w), Text("Cash", style: GoogleFonts.inter(fontSize: 14.sp))]),
                                Row(children: [Image.asset("assets/promo.png", height: 20.h, width: 20.w), SizedBox(width: 10.w), Text("Promo Code", style: GoogleFonts.inter(fontSize: 14.sp))]),
                                Row(children: [Image.asset("assets/note.png", height: 20.h, width: 20.w), SizedBox(width: 10.w), Text("Add Note", style: GoogleFonts.inter(fontSize: 14.sp))]),
                              ],
                            ),
                          ),

                          SizedBox(height: 10.h),

                          // Book Now Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: const Color(0xFF006970),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                            ),
                            onPressed: isBooking ? null : () async {
                              setState(() => isBooking = true);
                              try {
                                final selectedVehicle = snp.data[selectIndex];
                                final body = BookInstantDeliveryBodyModel(
                                  vehicleTypeId: selectedVehicle.vehicleTypeId,
                                  price: double.parse(selectedVehicle.price).toInt(),
                                  isCopanCode: false,
                                  copanId: null.toString(),
                                  copanAmount: 0,
                                  coinAmount: 0,
                                  taxAmount: 18,
                                  userPayAmount: double.parse(selectedVehicle.price).toInt(),
                                  distance: selectedVehicle.distance,
                                  mobNo: phon,
                                  name: name,
                                  origName: pickupAddress,
                                  origLat: widget.pickupLat,
                                  origLon: widget.pickupLon,
                                  destName: dropAddress,
                                  destLat: widget.dropLat,
                                  destLon: widget.dropLon,
                                  picUpType: selectedVehicle.picUpType,
                                );

                                final service = APIStateNetwork(callPrettyDio());
                                final response = await service.bookInstantDelivery(body);

                                if (response.code == 0) {
                                  box.put("current_booking_txId", response.data!.txId);
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => WaitingForDriverScreen(
                                        body: body,
                                        socket: socket!,
                                        pickupLat: pickupLat,
                                        pickupLon: pickupLon,
                                        dropLat: dropLat,
                                        dropLon: dropLon,
                                      ),
                                    ),
                                  );
                                  Fluttertoast.showToast(msg: "Delivery booked!");
                                } else {
                                  Fluttertoast.showToast(msg: response.message ?? "Booking failed");
                                }
                              } catch (e) {
                                Fluttertoast.showToast(msg: "Booking error");
                              } finally {
                                setState(() => isBooking = false);
                              }
                            },
                            child: isBooking
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text("Book Now", style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.white)),
                          ),

                          SizedBox(height: 20.h),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
        error: (e, s) => Center(child: Text(e.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}


class WaitingForDriverScreen extends StatefulWidget {
  final BookInstantDeliveryBodyModel body;
  final IO.Socket socket;
  final double pickupLat;
  final double pickupLon;
  final double dropLat;
  final double dropLon;

  const WaitingForDriverScreen({
    super.key,
    required this.body,
    required this.socket,
    required this.pickupLat,
    required this.pickupLon,
    required this.dropLat,
    required this.dropLon,
  });

  @override
  State<WaitingForDriverScreen> createState() => _WaitingForDriverScreenState();
}
class _WaitingForDriverScreenState extends State<WaitingForDriverScreen>
    with TickerProviderStateMixin {
  var box = Hive.box("folder");
  late IO.Socket _socket;
  late Timer _dotTimer;
  Timer? _searchTimer;
  int _dotCount = 1;
  bool _isSearching = true;
  int _remainingSeconds = 300; // 5 minutes

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];
  String? pickupToDropDistance;
  String? pickupToDropDuration;
  bool _routeFetched = false;

  late double pickupLat, pickupLon, dropLat, dropLon;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _socket = widget.socket;
    pickupLat = widget.pickupLat;
    pickupLon = widget.pickupLon;
    dropLat = widget.dropLat;
    dropLon = widget.dropLon;

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 30, end: 60).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );

    _setupEventListeners();
    _startSearching();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initMap();
    });
  }

  void _initMap() {
    _addMarkers();
    _fetchRoute();
  }

  void _setupEventListeners() {
    _socket.on('user:driver_assigned', _handleAssigned);
  }

  Future<void> _handleAssigned(dynamic payload) async {
    if (!mounted) return;

    try {
      if (payload is! Map) return;
      final deliveryId = payload['deliveryId'] as String?;
      if (deliveryId == null) return;

      final driver = payload['driver'] ?? {};
      final driverName =
      '${driver['firstName'] ?? ''} ${driver['lastName'] ?? ''}'.trim();
      final otp = payload['otp']?.toString() ?? 'N/A';

      Fluttertoast.showToast(msg: "Driver Assigned: $driverName");

      if (mounted) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => PickupScreen(
              socket: widget.socket,
              deliveryId: deliveryId,
              driver: driver as Map<String, dynamic>,
              otp: otp,
              pickup: payload['pickup'] ?? {},
              dropoff: payload['dropoff'] ?? {},
              amount: payload['amount'],
              vehicleType: payload['vehicleType'] ?? {},
              status: payload['status'].toString(),
              txId: box.get("current_booking_txId")?.toString() ?? '',
            ),
          ),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  void _addMarkers() {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(pickupLat, pickupLon),
        infoWindow: const InfoWindow(title: 'Pickup Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    _markers.add(
      Marker(
        markerId: const MarkerId('drop'),
        position: LatLng(dropLat, dropLon),
        infoWindow: const InfoWindow(title: 'Drop Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _fetchRoute() async {
    const String apiKey = 'AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g';
    String origin = '$pickupLat,$pickupLon';
    String dest = '$dropLat,$dropLon';
    Uri url = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': origin,
      'destination': dest,
      'key': apiKey,
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final String poly = data['routes'][0]['overview_polyline']['points'];
          _routePoints = _decodePolyline(poly);
          final leg = data['routes'][0]['legs'][0];
          pickupToDropDistance = leg['distance']['text'];
          pickupToDropDuration = leg['duration']['text'];
          _routeFetched = true;

          setState(() {
            _polylines.clear();
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('route'),
                points: _routePoints,
                color: Colors.blue,
                width: 5,
              ),
            );
          });

          if (_mapController != null && _routePoints.isNotEmpty) {
            LatLngBounds bounds = _calculateBounds(_routePoints);
            _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
          }
        }
      }
    } catch (e) {
      debugPrint('Route error: $e');
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = pickupLat, maxLat = pickupLat;
    double minLng = pickupLon, maxLng = pickupLon;

    for (LatLng p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    if (dropLat < minLat) minLat = dropLat;
    if (dropLat > maxLat) maxLat = dropLat;
    if (dropLon < minLng) minLng = dropLon;
    if (dropLon > maxLng) maxLng = dropLon;

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void _startDotTimer() {
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() => _dotCount = (_dotCount % 3) + 1);
      }
    });
  }

  void _startSearchTimer() {
    _searchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _stopSearching();
        }
      }
    });
  }

  void _startSearching() {
    setState(() {
      _isSearching = true;
      _remainingSeconds = 300; // 5 minutes
      _dotCount = 1;
    });
    _pulseController.repeat(reverse: true);
    _startDotTimer();
    _startSearchTimer();
  }

  void _stopSearching() {
    _dotTimer.cancel();
    _searchTimer?.cancel();
    _pulseController.stop();
    setState(() => _isSearching = false);
  }

  void _retrySearch() async {
    _stopSearching();
    setState(() => _isSearching = true);

    try {
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.bookInstantDelivery(widget.body);
      if (response.code == 0) {
        box.put("current_booking_txId", response.data!.txId);
        setState(() {
          _remainingSeconds = 300; // 5 minutes
          _dotCount = 1;
        });
        _pulseController.repeat(reverse: true);
        _startDotTimer();
        _startSearchTimer();
        Fluttertoast.showToast(msg: "Re-booking successful...");
      } else {
        setState(() => _isSearching = false);
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      setState(() => _isSearching = false);
      Fluttertoast.showToast(msg: "Retry failed: $e");
    }
  }

  // Format seconds to MM:SS
  String _formatTime(int seconds) {
    int min = seconds ~/ 60;
    int sec = seconds % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _socket.off('user:driver_assigned');
    _dotTimer.cancel();
    _searchTimer?.cancel();
    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _routeFetched
          ? Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(pickupLat, pickupLon),
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              _centerCameraOnPickup();
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Back Button
          Positioned(
            left: 10.w,
            top: 40.h,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
              onPressed: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.arrow_back_ios, color: Color(0xFF1D3557)),
              ),
            ),
          ),

          // PULSATING CIRCLE ON PICKUP
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: const Offset(0, -55),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: _pulseAnimation.value,
                        height: _pulseAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.6),
                            width: 2,
                          ),
                          color: Colors.blue.withOpacity(0.1),
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Route Info
          if (pickupToDropDistance != null)
            Positioned(
              bottom: 170.h,
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
                child: Text(
                  'Route: $pickupToDropDistance | $pickupToDropDuration',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // Search Status Bottom Sheet
          Positioned(
            bottom: 10.h,
            left: 16.w,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isSearching
                        ? "Searching for nearby drivers$dots"
                        : "No drivers found nearby",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  _isSearching
                      ? Text(
                    "Please wait... (${_formatTime(_remainingSeconds)})",
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                    textAlign: TextAlign.center,
                  )
                      : const Text(
                    "Try again or cancel request.",
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _isSearching
                      ? const CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.blueAccent,
                  )
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _retrySearch,
                    child: const Text(
                      "Try Again",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  void _centerCameraOnPickup() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(pickupLat, pickupLon),
          zoom: 15,
        ),
      ),
    );
  }
}