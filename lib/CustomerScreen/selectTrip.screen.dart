import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/MyOrderScreen.dart';
import 'package:delivery_mvp_app/CustomerScreen/pickup.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/selectPayment.screen.dart';
import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/bookInstantdeliveryBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/getDistanceBodyModel.dart';
import 'package:delivery_mvp_app/data/controller/bookInstantDeliveryController.dart';
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

class SelectTripScreen extends ConsumerStatefulWidget {
  // final GetDistanceBodyModel originalBody;
  const SelectTripScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    userId = box.get("id")?.toString(); // Safe cast
    if (userId == null) {
      log('❌ User ID missing from Hive!');
      // Handle: Navigate back or fetch ID
    } else {
      log('✅ User ID: $userId');
    }
    _getCurrentLocation();
    _connectSocket();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location service is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Please enable location service");
      return;
    }

    // Check location permission
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

    // Get current position
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    safeSetState(() {
      _currentPosition = position;
      _currentLatlng = LatLng(position.latitude, position.longitude);
    });

    log('📍 Current Location: ${position.latitude}, ${position.longitude}');
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
  void _connectSocket() {
    const socketUrl = 'http://192.168.1.43:4567';
    //const socketUrl = 'https://weloads.com';
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket', 'polling'], // Fallback
      'autoConnect': false,
      // 'auth': {'token': userToken},  // If needed
    });

    // ✅ Log all events for debugging
    socket!.onAny((event, data) {
      log("📡 SOCKET EVENT: $event → $data");
    });

    socket!.connect();

    socket!.onConnect((_) {
      log('✅ Socket connected');
      Fluttertoast.showToast(msg: "Socket connected");
      isSocketConnected = true;

      // ✅ FIRST: Emit registration with ACK
      if (userId != null) {
        final data = {
          'userId': userId,
          'role': 'customer', // Backend handler के अनुसार
        };
        socket!.emitWithAck(
          'registerCustomer',
          data,
          ack: (ackData) {
            log(
              '🔐 Registration ACK: $ackData',
            ); // Backend से response आएगा (e.g., success/error)
          },
        );
        log('📤 RegisterCustomer emitted: userId=$userId, role=customer');
      } else {
        log('❌ No userId for registration!');
      }

      // THEN: Start stream and setup listeners
      startLocationStream();
      _setupEventListeners();
      safeSetState(() {});
    });

    socket!.onDisconnect((_) {
      log('❌ Socket disconnected');
      Fluttertoast.showToast(msg: "Socket disconnected");
      isSocketConnected = false;
      safeSetState(() {});
    });

    socket!.onReconnect((data) {
      log(
        '🔄 Reconnected Event Triggered | Raw data: $data (${data.runtimeType})',
      );
      // Socket.IO usually sends attempt count as int
      int? attempt;
      if (data is Map && data.containsKey('data')) {
        attempt = data['data']['attempts'];
      } else if (data is int) {
        attempt = data;
      }
      log('🔄 Reconnected${attempt != null ? ' (Attempt $attempt)' : ''}');
      isSocketConnected = true;
      safeSetState(() {});
      // Re-join logic
      socket!.emit('join:user', {'userId': userId});
      _setupEventListeners();
    });

    socket!.onReconnectError((error) {
      log('❌ Reconnect error: $error');
    });
  }

  // ✅ Centralized method to set up event listeners (avoids duplicates)
  void _setupEventListeners() {
    // _listenersSetup = true;

    // ✅ MESSAGE EVENT (removed driver_assigned listener as it's handled in Waiting screen)
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: _currentLatlng == null
                    ? Center(child: CircularProgressIndicator())
                    : Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: _currentLatlng!,
                              zoom: 15,
                            ),
                            onMapCreated: (controller) {
                              _mapController = controller;
                            },
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                          ),
                          Positioned(
                            left: 10.w,
                            top: 40.h,
                            child: FloatingActionButton(
                              mini: true,
                              backgroundColor: Color(0xFFFFFFFF),
                              shape: CircleBorder(),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(left: 10.w),
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: Color(0xFF1D3557),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              SizedBox(height: 10.h),
              Container(
                height: 200.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  //color: Colors.amber,
                ),
                child: ListView.builder(
                  itemCount: snp.data.length,
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final isSelected = selectIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: isSelected ? 0.h : 10.h,
                        ),
                        width: 130.w,
                        height: isSelected ? 180.h : 170.h,
                        decoration: BoxDecoration(
                          color: isSelected ? Color(0xFFE5F0F1) : Colors.white,
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
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.h),
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
                              margin: EdgeInsets.only(top: 10.h),
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
                              padding: EdgeInsets.only(left: 10.w, top: 10.h),
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
                              padding: EdgeInsets.only(left: 10.w),
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
              Container(
                margin: EdgeInsets.only(left: 15.w, right: 15.w, top: 10.h),
                width: MediaQuery.of(context).size.width,
                height: 50.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.grey, strokeAlign: 1.w),
                ),
                child: Row(
                  children: [
                    methodPay("assets/SvgImage/cashes.svg"),
                    methodPay("assets/SvgImage/addpromo.svg"),
                    methodPay("assets/SvgImage/ed.svg"),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.w, right: 15.w),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50.h),
                    backgroundColor: Color(0xFF006970),
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
                              //selectedVehicle.vehicleType,
                              price: double.parse(
                                selectedVehicle.price,
                              ).toInt(),
                              //                                             price: (selectedVehicle.price.contains('.'))
                              // ? double.parse(selectedVehicle.price).toInt()
                              // : int.parse(selectedVehicle.price),
                              isCopanCode: false,
                              copanId: null.toString(),
                              copanAmount: 0,
                              coinAmount: 0,
                              taxAmount: 18,
                              userPayAmount: double.parse(
                                selectedVehicle.price,
                              ).toInt(),
                              distance: selectedVehicle.distance,
                              // mobNo: selectedVehicle.mobNo,
                              mobNo: "98767655678",
                              name: selectedVehicle.name,
                              // origName: selectedVehicle.origName,
                              // origLat: selectedVehicle.origLat,
                              // origLon: selectedVehicle.origLon,
                              origName: "jaipur",
                              origLat: 26.9124,
                              origLon: 75.7873,
                              destName: selectedVehicle.destName,
                              destLat: selectedVehicle.destLat,
                              destLon: selectedVehicle.destLon,
                              picUpType: selectedVehicle.picUpType,
                            );
                            final service = APIStateNetwork(callPrettyDio());
                            final response = await service.bookInstantDelivery(
                              body,
                            );
                            if (response.code == 0) {
                              box.put(
                                "current_booking_txId",
                                response.data!.txId,
                              );
                              log(
                                '✅ Booking created — txId: ${response.data!.txId}',
                              );
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => WaitingForDriverScreen(
                                    body: body,
                                    socket: socket!,
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
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) {
          log(stackTrace.toString());
          return Center(child: Text(error.toString()));
        },
        loading: () => Center(child: CircularProgressIndicator()),
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

class WaitingForDriverScreen extends StatefulWidget {
  final BookInstantDeliveryBodyModel body;
  final IO.Socket socket;

  const WaitingForDriverScreen({
    super.key,
    required this.body,
    required this.socket,
  });

  @override
  State<WaitingForDriverScreen> createState() => _WaitingForDriverScreenState();
}

class _WaitingForDriverScreenState extends State<WaitingForDriverScreen> {
  var box = Hive.box("folder");
  late IO.Socket _socket;
  late Timer _dotTimer;
  Timer? _pulseTimer;
  Timer? _searchTimer;

  int _dotCount = 1;
  double _radius = 30;
  bool _isSearching = true; // 👈 Controls search state
  int _remainingSeconds = 30; // 👈 Countdown timer (optional)

  @override
  void initState() {
    super.initState();
    _socket = widget.socket;
    _setupEventListeners();
    _startSearching();
  }

  void _setupEventListeners() {
    _socket.on('user:driver_assigned', _handleAssigned);
  }

  Future<void> _handleAssigned(dynamic payload) async {
    if (!mounted) return;

    log(
      '👨‍✈️ DRIVER ASSIGNED FULL PAYLOAD:\n${const JsonEncoder.withIndent('  ').convert(payload)}',
    );

    try {
      if (payload is! Map) {
        log('⚠️ Invalid payload type: ${payload.runtimeType}');
        return;
      }

      log('🧾 Payload keys: ${payload.keys.join(', ')}');

      final deliveryId = payload['deliveryId'] as String?;
      if (deliveryId == null) {
        log('⚠️ Missing deliveryId in payload');
        return;
      }
      log("✅ Delivery Assigned: $deliveryId");

      // ✅ Define all fields before using
      final driver = payload['driver'] ?? {};
      final driverFirstName = driver['firstName'] ?? '';
      final driverLastName = driver['lastName'] ?? '';
      final driverName = '$driverFirstName $driverLastName'.trim();
      final driverPhone = driver['phone'] ?? 'N/A';
      final driverRating = driver['averageRating'] ?? 'N/A';

      final otp = payload['otp']?.toString() ?? 'N/A';
      final amount = payload['amount'] ?? 'N/A';
      final vehicleType = payload['vehicleType'] ?? {};
      final pickup = payload['pickup'] ?? {};
      final dropoff = payload['dropoff'] ?? {};
      final status = payload['status'] ?? 'N/A';

      Fluttertoast.showToast(
        msg: "Driver Assigned : $driverName",
        toastLength: Toast.LENGTH_LONG,
      );

      // Handle OTP
      if (payload.containsKey('otp')) {
        final otp = payload['otp'].toString();
        log('🔑 OTP Received: $otp');
      }

      // Navigate
      if (mounted) {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => PickupScreen(
              deliveryId: deliveryId,
              driver: driver as Map<String, dynamic>,
              otp: otp,
              pickup: pickup as Map<String, dynamic>,
              dropoff: dropoff as Map<String, dynamic>,
              amount: amount,
              vehicleType: vehicleType as Map<String, dynamic>,
              status: status.toString(),
              txId: box.get("current_booking_txId")?.toString() ?? '',
            ),
          ),
        );
      }
    } catch (e, st) {
      log('⚠️ Error parsing driver data: $e');
      log('Stack trace: $st');
      log('Payload type: ${payload.runtimeType}');
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void _startDotTimer() {
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount % 3) + 1;
        });
      }
    });
  }

  void _startPulseTimer() {
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted) {
        setState(() {
          _radius = _radius == 30 ? 50 : 30;
        });
      }
    });
  }

  void _startSearchTimer() {
    _searchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          _stopSearching();
        }
      }
    });
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

  void _stopSearching() {
    _dotTimer.cancel();
    _pulseTimer?.cancel();
    _searchTimer?.cancel();
    setState(() {
      _isSearching = false;
    });
  }

  void _retrySearch() async {
    _stopSearching();
    setState(() {
      _isSearching = true;
    });

    try {
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.bookInstantDelivery(widget.body);
      if (response.code == 0) {
        box.put("current_booking_txId", response.data!.txId);
        log('✅ Re-booked — new txId: ${response.data!.txId}');

        setState(() {
          _remainingSeconds = 15;
          _dotCount = 1;
          _radius = 30;
        });

        _startDotTimer();
        _startPulseTimer();
        _startSearchTimer();

        Fluttertoast.showToast(
          msg: "Re-booking successful, searching again...",
        );
      } else {
        setState(() => _isSearching = false);
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e, st) {
      setState(() => _isSearching = false);
      log("Retry error: $e / $st");
      Fluttertoast.showToast(msg: "Failed to re-book: $e");
    }
  }

  @override
  void dispose() {
    _socket.off('user:driver_assigned');
    _dotTimer.cancel();
    _pulseTimer?.cancel();
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsating circle animation
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                width: _radius * 2,
                height: _radius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.1),
                  border: Border.all(color: Colors.blueAccent, width: 2),
                ),
                child: Center(
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            Text(
              _isSearching
                  ? "Searching for nearby drivers$dots"
                  : "No drivers found nearby",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            _isSearching
                ? Text(
                    "Please wait while we connect you to a driver.\n(${_remainingSeconds}s)",
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                    textAlign: TextAlign.center,
                  )
                : const Text(
                    "Please try again or cancel your request.",
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),

            const SizedBox(height: 50),

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
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}


//////////////////////////  old Design /////////////////////////////////

// Container(
              //   margin: EdgeInsets.only(top: 10.h, left: 20.w, right: 20.w),
              //   padding: EdgeInsets.only(
              //     left: 12.w,
              //     right: 12.w,
              //     top: 18.h,
              //     bottom: 18.h,
              //   ),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(15.r),
              //     boxShadow: [
              //       BoxShadow(
              //         offset: Offset(0, 2),
              //         blurRadius: 3,
              //         spreadRadius: 2,
              //         color: Color.fromARGB(28, 0, 0, 0),
              //       ),
              //     ],
              //   ),
              //   child: Column(
              //     children: [
              //       Row(
              //         children: [
              //           Icon(Icons.circle, size: 12.sp, color: Colors.green),
              //           SizedBox(width: 10.w),
              //           Expanded(
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Text.rich(
              //                   TextSpan(
              //                     children: [
              //                       TextSpan(
              //                         text: "${name} ·",
              //                         style: GoogleFonts.poppins(
              //                           fontWeight: FontWeight.w500,
              //                           fontSize: 15.sp,
              //                         ),
              //                       ),
              //                       TextSpan(
              //                         text: " ${phon}",
              //                         style: GoogleFonts.poppins(
              //                           fontWeight: FontWeight.w400,
              //                           fontSize: 13.sp,
              //                           color: Colors.grey[700],
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                 ),
              //                 SizedBox(height: 2.h),
              //                 Text(
              //                   maxLines: 1,
              //                   overflow: TextOverflow.ellipsis,
              //                   // "60 Feet Rd, Sanjay Nagar, Jagann...",
              //                   pickupAddress,
              //                   style: GoogleFonts.poppins(
              //                     fontSize: 14.sp,
              //                     color: Colors.grey[800],
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ],
              //       ),
              //       SizedBox(height: 15.h),
              //       Row(
              //         children: [
              //           Icon(Icons.location_on, size: 14.sp, color: Colors.red),
              //           SizedBox(width: 10.w),
              //           Expanded(
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Text.rich(
              //                   TextSpan(
              //                     children: [
              //                       TextSpan(
              //                         text: "${name} ·",
              //                         style: GoogleFonts.poppins(
              //                           fontWeight: FontWeight.w500,
              //                           fontSize: 15.sp,
              //                         ),
              //                       ),
              //                       TextSpan(
              //                         text: " ${phon}",
              //                         style: GoogleFonts.poppins(
              //                           fontWeight: FontWeight.w400,
              //                           fontSize: 13.sp,
              //                           color: Colors.grey[700],
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                 ),
              //                 SizedBox(height: 2.h),
              //                 Text(
              //                   maxLines: 1,
              //                   overflow: TextOverflow.ellipsis,
              //                   dropAddress,
              //                   style: GoogleFonts.poppins(
              //                     fontSize: 14.sp,
              //                     color: Colors.grey[800],
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              // SizedBox(height: 10.h),
              // Expanded(
              //   child: Container(
              //     padding: EdgeInsets.symmetric(horizontal: 16.w),
              //     decoration: BoxDecoration(
              //       color: Color(0xFFFFFFFF),
              //       borderRadius: BorderRadius.only(
              //         topLeft: Radius.circular(16.r),
              //         topRight: Radius.circular(16.r),
              //       ),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black12,
              //           blurRadius: 10,
              //           spreadRadius: 5,
              //         ),
              //       ],
              //     ),
              //     child: ListView(
              //       padding: EdgeInsets.zero,
              //       children: [
              //         SizedBox(height: 8.h),
              //         Center(
              //           child: Container(
              //             width: 50.w,
              //             height: 4.h,
              //             decoration: BoxDecoration(
              //               color: Colors.grey[300],
              //               borderRadius: BorderRadius.circular(10.r),
              //             ),
              //           ),
              //         ),
              //         SizedBox(height: 8.h),
              //         Center(
              //           child: Text(
              //             "Choose a Trip",
              //             style: GoogleFonts.inter(
              //               fontSize: 18.sp,
              //               fontWeight: FontWeight.w600,
              //               color: Color(0xFF000000),
              //               letterSpacing: -1,
              //             ),
              //           ),
              //         ),
              //         SizedBox(height: 10.h),
              //         Container(
              //           width: double.infinity,
              //           height: 170.h,
              //           decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(20.r),
              //             border: Border.all(
              //               color: Color(0xFF000000),
              //               width: 3,
              //             ),
              //           ),
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               SizedBox(height: 10.h),
              //               Center(
              //                 child: Image.network(
              //                   // "assets/car.png",
              //                   snp.data[selectIndex].image,
              //                   width: 110.w,
              //                   height: 70.h,
              //                   fit: BoxFit.contain,
              //                   errorBuilder: (context, error, stackTrace) {
              //                     return Image.asset(
              //                       "assets/car.png",
              //                       width: 106.w,
              //                       height: 60.h,
              //                       fit: BoxFit.cover,
              //                     );
              //                   },
              //                 ),
              //               ),
              //               Row(
              //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                 children: [
              //                   Padding(
              //                     padding: EdgeInsets.only(left: 18.w),
              //                     child: Text(
              //                       //Delivery Go
              //                       "${snp.data[selectIndex].vehicleType}",
              //                       style: GoogleFonts.inter(
              //                         fontSize: 18.sp,
              //                         fontWeight: FontWeight.w500,
              //                         color: Color(0xfF000000),
              //                         letterSpacing: -0.5,
              //                       ),
              //                     ),
              //                   ),
              //                   Padding(
              //                     padding: EdgeInsets.only(right: 18.w),
              //                     child: Text(
              //                       // "₹170.71",
              //                       "₹${snp.data[selectIndex].price}",
              //                       style: GoogleFonts.inter(
              //                         fontSize: 18.sp,
              //                         fontWeight: FontWeight.w500,
              //                         color: Color(0xfF000000),
              //                         letterSpacing: -0.5,
              //                       ),
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //               Padding(
              //                 padding: EdgeInsets.only(left: 18.w),
              //                 child: Row(
              //                   children: [
              //                     Text(
              //                       "8:46pm",
              //                       style: GoogleFonts.inter(
              //                         fontSize: 14.sp,
              //                         fontWeight: FontWeight.w400,
              //                         color: Color(0xFF000000),
              //                         letterSpacing: 1,
              //                       ),
              //                     ),
              //                     SizedBox(width: 6.w),
              //                     CircleAvatar(
              //                       radius: 4.r,
              //                       backgroundColor: Color(0xFFD9D9D9),
              //                     ),
              //                     SizedBox(width: 6.w),
              //                     Text(
              //                       "4 min away",
              //                       style: GoogleFonts.inter(
              //                         fontSize: 14.sp,
              //                         fontWeight: FontWeight.w400,
              //                         color: Color(0xFF000000),
              //                         letterSpacing: 1,
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //               ),
              //               SizedBox(height: 5.h),
              //               Container(
              //                 margin: EdgeInsets.only(left: 18.w),
              //                 width: 65.w,
              //                 height: 22.h,
              //                 decoration: BoxDecoration(
              //                   borderRadius: BorderRadius.circular(4.r),
              //                   color: const Color(0xFF3B6CE9),
              //                 ),
              //                 child: Row(
              //                   mainAxisAlignment: MainAxisAlignment.center,
              //                   crossAxisAlignment: CrossAxisAlignment.center,
              //                   children: [
              //                     Icon(
              //                       Icons.bolt,
              //                       color: Colors.white,
              //                       size: 16.sp,
              //                     ),
              //                     SizedBox(width: 3.w),
              //                     Text(
              //                       "Faster",
              //                       style: GoogleFonts.inter(
              //                         fontSize: 12.sp,
              //                         fontWeight: FontWeight.w500,
              //                         color: Colors.white,
              //                         letterSpacing: -0.5,
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //         SizedBox(height: 25.h),
              //         ListView.builder(
              //           padding: EdgeInsets.zero,
              //           physics: const NeverScrollableScrollPhysics(),
              //           shrinkWrap: true,
              //           itemCount: snp.data.length,
              //           itemBuilder: (context, index) {
              //             return InkWell(
              //               onTap: () {
              //                 setState(() {
              //                   selectIndex = index;
              //                 });
              //               },
              //               child: Padding(
              //                 padding: EdgeInsets.only(
              //                   bottom: 20.h,
              //                   left: 5.w,
              //                   right: 5.w,
              //                 ),
              //                 child: Container(
              //                   padding: EdgeInsets.only(
              //                     left: 10.w,
              //                     right: 12.w,
              //                     top: 10.h,
              //                     bottom: 10.h,
              //                   ),
              //                   decoration: BoxDecoration(
              //                     borderRadius: BorderRadius.circular(10.r),
              //                     border: Border.all(
              //                       color: selectIndex == index
              //                           ? Color.fromARGB(127, 0, 0, 0)
              //                           : Colors.transparent,
              //                       width: 1.w,
              //                     ),
              //                   ),
              //                   child: Row(
              //                     children: [
              //                       Image.network(
              //                         // "assets/b.png",
              //                         //selectTrip[index]["image"].toString(),
              //                         snp.data[index].image,
              //                         width: 50.w,
              //                         height: 50.h,
              //                         fit: BoxFit.contain,
              //                         errorBuilder: (context, error, stackTrace) {
              //                           return Image.asset(
              //                             // "https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/624px-No-Image-Placeholder.svg.png",
              //                             "assets/b.png",
              //                             width: 50.w,
              //                             height: 50.h,
              //                             fit: BoxFit.contain,
              //                           );
              //                         },
              //                       ),
              //                       SizedBox(width: 10.w),
              //                       Column(
              //                         crossAxisAlignment:
              //                             CrossAxisAlignment.start,
              //                         children: [
              //                           Text(
              //                             //"Delivery Go",
              //                             // selectTrip[index]['name'],
              //                             snp.data[index].vehicleType,
              //                             style: GoogleFonts.inter(
              //                               fontSize: 18.sp,
              //                               fontWeight: FontWeight.w400,
              //                               color: Color(0xff000000),
              //                               letterSpacing: -1,
              //                             ),
              //                           ),
              //                           Row(
              //                             children: [
              //                               Text(
              //                                 "8:46pm",
              //                                 style: GoogleFonts.inter(
              //                                   fontSize: 14.sp,
              //                                   fontWeight: FontWeight.w400,
              //                                   color: Color(0xFF000000),
              //                                   letterSpacing: -0.5,
              //                                 ),
              //                               ),
              //                               SizedBox(width: 6.w),
              //                               CircleAvatar(
              //                                 radius: 3.r,
              //                                 backgroundColor: Color(
              //                                   0xFFD9D9D9,
              //                                 ),
              //                               ),
              //                               SizedBox(width: 6.w),
              //                               Text(
              //                                 "4 min away",
              //                                 style: GoogleFonts.inter(
              //                                   fontSize: 14.sp,
              //                                   fontWeight: FontWeight.w400,
              //                                   color: Color(0xFF000000),
              //                                   letterSpacing: -0.5,
              //                                 ),
              //                               ),
              //                             ],
              //                           ),
              //                         ],
              //                       ),
              //                       Spacer(),
              //                       Column(
              //                         crossAxisAlignment:
              //                             CrossAxisAlignment.start,
              //                         children: [
              //                           Text(
              //                             // "₹170.71",
              //                             // selectTrip[index]['ammount'],
              //                             "₹${snp.data[index].price}",
              //                             style: GoogleFonts.inter(
              //                               fontSize: 18.sp,
              //                               fontWeight: FontWeight.w500,
              //                               color: Color(0xfF000000),
              //                               letterSpacing: -1,
              //                             ),
              //                           ),
              //                           if (index == 0 || index == 1)
              //                             Text(
              //                               //"₹188.71",
              //                               selectTrip[index]['discount'],
              //                               style: GoogleFonts.inter(
              //                                 fontSize: 14.sp,
              //                                 fontWeight: FontWeight.w400,
              //                                 color: Color(0xFF6B6B6B),
              //                                 letterSpacing: 0,
              //                                 decoration:
              //                                     TextDecoration.lineThrough,
              //                                 decorationColor: Color(
              //                                   0xFF6B6B6B,
              //                                 ),
              //                               ),
              //                             ),
              //                         ],
              //                       ),
              //                     ],
              //                   ),
              //                 ),
              //               ),
              //             );
              //           },
              //         ),
              //         SizedBox(height: 15.h),
              //         Container(
              //           width: MediaQuery.of(context).size.width,
              //           height: 50.h,
              //           decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(10.r),
              //             border: Border.all(
              //               color: Colors.grey,
              //               strokeAlign: 1.w,
              //             ),
              //           ),
              //           child: Row(
              //             children: [
              //               methodPay("assets/SvgImage/cashes.svg"),
              //               methodPay("assets/SvgImage/addpromo.svg"),
              //               methodPay("assets/SvgImage/ed.svg"),
              //             ],
              //           ),
              //         ),
              //         SizedBox(height: 15.h),
              //         ElevatedButton(
              //           style: ElevatedButton.styleFrom(
              //             minimumSize: Size(double.infinity, 50.h),
              //             backgroundColor: Color(0xFF006970),
              //             shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(10.r),
              //             ),
              //           ),
              //           onPressed: isBooking
              //               ? null
              //               : () async {
              //                   setState(() => isBooking = true);
              //                   try {
              //                     final selectedVehicle = snp.data[selectIndex];
              //                     final body = BookInstantDeliveryBodyModel(
              //                       vehicleTypeId:
              //                           selectedVehicle.vehicleTypeId,
              //                       //selectedVehicle.vehicleType,
              //                       price: double.parse(
              //                         selectedVehicle.price,
              //                       ).toInt(),
              //                       //                                             price: (selectedVehicle.price.contains('.'))
              //                       // ? double.parse(selectedVehicle.price).toInt()
              //                       // : int.parse(selectedVehicle.price),
              //                       isCopanCode: false,
              //                       copanId: null.toString(),
              //                       copanAmount: 0,
              //                       coinAmount: 0,
              //                       taxAmount: 18,
              //                       userPayAmount: double.parse(
              //                         selectedVehicle.price,
              //                       ).toInt(),
              //                       distance: selectedVehicle.distance,
              //                       // mobNo: selectedVehicle.mobNo,
              //                       mobNo: "98767655678",
              //                       name: selectedVehicle.name,
              //                       // origName: selectedVehicle.origName,
              //                       // origLat: selectedVehicle.origLat,
              //                       // origLon: selectedVehicle.origLon,
              //                       origName: "jaipur",
              //                       origLat: 26.9124,
              //                       origLon: 75.7873,
              //                       destName: selectedVehicle.destName,
              //                       destLat: selectedVehicle.destLat,
              //                       destLon: selectedVehicle.destLon,
              //                       picUpType: selectedVehicle.picUpType,
              //                     );
              //                     final service = APIStateNetwork(
              //                       callPrettyDio(),
              //                     );
              //                     final response = await service
              //                         .bookInstantDelivery(body);
              //                     if (response.code == 0) {
              //                       box.put(
              //                         "current_booking_txId",
              //                         response.data!.txId,
              //                       );
              //                       log(
              //                         '✅ Booking created — txId: ${response.data!.txId}',
              //                       );
              //                       Navigator.push(
              //                         context,
              //                         CupertinoPageRoute(
              //                           builder: (context) =>
              //                               WaitingForDriverScreen(
              //                                 body: body,
              //                                 socket: socket!,
              //                               ),
              //                           fullscreenDialog: true,
              //                         ),
              //                       );
              //                       Fluttertoast.showToast(
              //                         msg:
              //                             "Delivery booked, waiting for driver...",
              //                       );
              //                       setState(() {
              //                         isBooking = false;
              //                       });
              //                     } else {
              //                       Fluttertoast.showToast(
              //                         msg: response.message,
              //                       );
              //                       setState(() {
              //                         isBooking = false;
              //                       });
              //                     }
              //                   } catch (e, st) {
              //                     setState(() {
              //                       isBooking = false;
              //                     });
              //                     log("${e.toString()} / ${st.toString()}");
              //                     ScaffoldMessenger.of(context).showSnackBar(
              //                       SnackBar(
              //                         content: Text("Booking failed: $e"),
              //                         behavior: SnackBarBehavior.floating,
              //                         margin: EdgeInsets.only(
              //                           left: 15.w,
              //                           bottom: 15.h,
              //                           right: 15.w,
              //                         ),
              //                         shape: RoundedRectangleBorder(
              //                           borderRadius: BorderRadius.circular(
              //                             15.r,
              //                           ),
              //                           side: BorderSide.none,
              //                         ),
              //                         backgroundColor: Colors.red,
              //                       ),
              //                     );
              //                   }
              //                 },
              //           child: isBooking
              //               ? Center(
              //                   child: SizedBox(
              //                     width: 30.w,
              //                     height: 30.h,
              //                     child: CircularProgressIndicator(
              //                       color: Colors.white,
              //                       strokeWidth: 2.w,
              //                     ),
              //                   ),
              //                 )
              //               : Text(
              //                   "Book Now",
              //                   style: GoogleFonts.inter(
              //                     fontSize: 16.sp,
              //                     fontWeight: FontWeight.w400,
              //                     color: Color(0xFFFFFFFF),
              //                   ),
              //                 ),
              //         ),
              //         SizedBox(height: 10.h),
              //       ],
              //     ),
              //   ),
              // ),