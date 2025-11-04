/*
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/bookInstantdeliveryBodyModel.dart';
import 'package:delivery_mvp_app/CustomerScreen/pickup.screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

class WaitingForDriverScreen extends StatefulWidget {
  final BookInstantDeliveryBodyModel body;
  final double pickupLat, pickupLon, dropLat, dropLon;

  const WaitingForDriverScreen({
    super.key,
    required this.body,
    required this.pickupLat,
    required this.pickupLon,
    required this.dropLat,
    required this.dropLon,
  });

  @override
  State<WaitingForDriverScreen> createState() => _WaitingForDriverScreenState();
}

class _WaitingForDriverScreenState extends State<WaitingForDriverScreen> {
  var box = Hive.box("folder");
  late IO.Socket _socket;
  String? userId;
  Timer? _dotTimer, _pulseTimer, _searchTimer;
  int _dotCount = 1;
  double _radius = 30;
  bool _isSearching = true;
  int _remainingSeconds = 15;

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];
  String? pickupToDropDistance;
  String? pickupToDropDuration;
  bool _routeFetched = false;

  @override
  void initState() {
    super.initState();
    userId = box.get("id")?.toString();
    _connectSocket();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initMap());
  }

  void _initMap() {
    _addMarkers();
    _fetchRoute();
  }

  void _connectSocket() {
    const socketUrl = 'http://192.168.1.43:4567';
    _socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.connect();

    _socket.onConnect((_) {
      log('New Socket Connected in WaitingScreen');
      if (userId != null) {
        _socket.emitWithAck('registerCustomer', {
          'userId': userId,
          'role': 'customer'
        }, ack: (data) => log('Register ACK: $data'));
      }
      _setupEventListeners();
    });

    _socket.onDisconnect((_) => log('Socket disconnected in WaitingScreen'));
  }

  void _setupEventListeners() {
    _socket.off('user:driver_assigned');
    _socket.on('user:driver_assigned', _handleAssigned);
  }

  Future<void> _handleAssigned(dynamic payload) async {
    if (!mounted) return;
    log('DRIVER ASSIGNED: $payload');

    try {
      final deliveryId = payload['deliveryId'] as String?;
      if (deliveryId == null) return;

      final driver = payload['driver'] ?? {};
      final driverName = '${driver['firstName'] ?? ''} ${driver['lastName'] ?? ''}'.trim();
      final otp = payload['otp']?.toString() ?? 'N/A';

      Fluttertoast.showToast(msg: "Driver Assigned: $driverName");

      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => PickupScreen(
            socket: ,
            deliveryId: deliveryId,
            driver: driver,
            otp: otp,
            pickup: payload['pickup'] ?? {},
            dropoff: payload['dropoff'] ?? {},
            amount: payload['amount'],
            vehicleType: payload['vehicleType'] ?? {},
            status: payload['status']?.toString() ?? '',
            txId: box.get("current_booking_txId") ?? '',
          ),
        ),
      );
    } catch (e) {
      log('Parse error: $e');
    }
  }

  void _addMarkers() {
    _markers.clear();
    _markers.add(Marker(
      markerId: const MarkerId('pickup'),
      position: LatLng(widget.pickupLat, widget.pickupLon),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
    _markers.add(Marker(
      markerId: const MarkerId('drop'),
      position: LatLng(widget.dropLat, widget.dropLon),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    ));
    if (mounted) setState(() {});
  }

  Future<void> _fetchRoute() async {
    const apiKey = 'AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g';
    final url = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': '${widget.pickupLat},${widget.pickupLon}',
      'destination': '${widget.dropLat},${widget.dropLon}',
      'key': apiKey,
    });

    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['status'] == 'OK') {
          final poly = data['routes'][0]['overview_polyline']['points'];
          _routePoints = _decodePolyline(poly);
          final leg = data['routes'][0]['legs'][0];
          pickupToDropDistance = leg['distance']['text'];
          pickupToDropDuration = leg['duration']['text'];
          _routeFetched = true;

          if (mounted) {
            setState(() {
              _polylines.add(Polyline(
                polylineId: const PolylineId('route'),
                points: _routePoints,
                color: Colors.blue,
                width: 5,
              ));
            });
            if (_mapController != null) {
              final bounds = _calculateBounds(_routePoints);
              _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
            }
          }
        }
      }
    } catch (e) {
      log('Route fetch error: $e');
    }
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

  void _startSearching() {
    setState(() {
      _isSearching = true;
      _remainingSeconds = 15;
      _dotCount = 1;
      _radius = 30;
    });
    _startDotTimer();
    _startPulseTimer();
    _startSearchTimer();
  }

  void _startDotTimer() {
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() => _dotCount = (_dotCount % 3) + 1);
    });
  }

  void _startPulseTimer() {
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (mounted) setState(() => _radius = _radius == 30 ? 50 : 30);
    });
  }

  void _startSearchTimer() {
    _searchTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _stopSearching();
        }
      }
    });
  }

  void _stopSearching() {
    _dotTimer?.cancel();
    _pulseTimer?.cancel();
    _searchTimer?.cancel();
    if (mounted) setState(() => _isSearching = false);
  }

  void _retrySearch() async {
    _stopSearching();

    // Reconnect socket
    if (_socket.connected) _socket.disconnect();
    _connectSocket();
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.bookInstantDelivery(widget.body);
      if (response.code == 0) {
        box.put("current_booking_txId", response.data!.txId);
        _startSearching();
        Fluttertoast.showToast(msg: "Searching again...");
      } else {
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Retry failed");
    }
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    _pulseTimer?.cancel();
    _searchTimer?.cancel();
    _socket.off('user:driver_assigned');
    if (_socket.connected) _socket.disconnect();
    _socket.dispose();
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
          GoogleMap(
            initialCameraPosition: CameraPosition(target: LatLng(widget.pickupLat, widget.pickupLon), zoom: 12),
            onMapCreated: (c) {
              _mapController = c;
              if (_routePoints.isNotEmpty) {
                final bounds = _calculateBounds(_routePoints);
                _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
              }
            },
            markers: _markers,
            polylines: _polylines,
          ),
          Positioned(
            left: 10.w,
            top: 40.h,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
              onPressed: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios, color: Color(0xFF1D3557)),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                width: _radius * 2,
                height: _radius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.1),
                  border: Border.all(color: Colors.blueAccent, width: 2),
                ),
                child: const Center(child: CircleAvatar(radius: 12, backgroundColor: Colors.blueAccent)),
              ),
            ),
          ),
          if (pickupToDropDistance != null)
            Positioned(
              bottom: 170.h,
              left: 16.w,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]),
                child: Text('Route: $pickupToDropDistance | $pickupToDropDuration', style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              ),
            ),
          Positioned(
            bottom: 10.h,
            left: 16.w,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
              child: Column(
                children: [
                  Text(_isSearching ? "Searching for drivers$dots" : "No drivers found", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  _isSearching
                      ? Text("Please wait ($_remainingSeconds s)", style: const TextStyle(fontSize: 15, color: Colors.grey))
                      : const Text("Try again or cancel", style: TextStyle(fontSize: 15, color: Colors.grey)),
                  const SizedBox(height: 16),
                  _isSearching
                      ? const CircularProgressIndicator(color: Colors.blueAccent)
                      : ElevatedButton(onPressed: _retrySearch, child: const Text("Try Again")),
                ],
              ),
            ),
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}*/
