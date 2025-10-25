


import 'dart:async';
import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/MyOrderScreen.dart';
import 'package:delivery_mvp_app/CustomerScreen/pickup.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/selectPayment.screen.dart';
import 'package:delivery_mvp_app/data/Model/bookInstantdeliveryBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/getDistanceBodyModel.dart';
import 'package:delivery_mvp_app/data/controller/bookInstantDeliveryController.dart';
import 'package:delivery_mvp_app/data/controller/getDistanceController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  bool _isCheckingLocation = true;
  Position? _currentPosition;
  String? currentAddress;
  StreamSubscription<Position>? _locationSubscription;
  String? userId;  // Cache it

  @override
  void initState() {
    super.initState();
    userId = box.get("id")?.toString();  // Safe cast
    if (userId == null) {
      log('❌ User ID missing from Hive!');
      // Handle: Navigate back or fetch ID
    } else {
      log('✅ User ID: $userId');
    }
    _connectSocket();
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
      socket!.emitWithAck('user:location_update', {
        'userId': userId,
        'lat': lat,
        'lon': lon,
      }, ack: (data) {
        log('📤 Location ACK: $data');  // Server confirms receipt
      });
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
    // const socketUrl = 'https://weloads.com';
    const socketUrl = 'hhttp://192.168.1.43:4567';
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket', 'polling'],  // Fallback
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
          'role': 'customer'  // Backend handler के अनुसार
        };
        socket!.emitWithAck('registerCustomer', data, ack: (ackData) {
          log('🔐 Registration ACK: $ackData');  // Backend से response आएगा (e.g., success/error)
        });
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
  }

  void _setupEventListeners() {
    socket!.on('user:driver_assigned', _handleAssigned);
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

  Future<void> _handleAssigned(dynamic payload) async {
    if (!mounted) return;
    log('👨‍✈️ Driver Assigned RAW: $payload');  // Full payload

    try {
      final deliveryId = payload['deliveryId'] as String?;
      if (deliveryId == null) {
        log('⚠️ Missing deliveryId in payload');
        return;
      }
      print("✅ Delivery Assigned: $deliveryId");

      final driver = payload['driver'] ?? payload;  // Fallback to whole payload
      final driverName = driver?['name'] ?? 'Unknown';
      final driverPhone = driver?['phone'] ?? 'N/A';

      Fluttertoast.showToast(
        msg: "Driver Assigned: $driverName ($driverPhone)",
        toastLength: Toast.LENGTH_LONG,
      );

      safeSetState(() {
        assignedDriver = driver as Map<String, dynamic>?;
        // Add more state updates here if needed, e.g., currentDeliveryId = deliveryId;
      });

      // Optional: Handle OTP or other data from payload
      if (payload.containsKey('otp')) {
        final otp = payload['otp'] as String;
        log('🔑 OTP Received: $otp');
        // Store or display OTP
      }

      // ✅ Navigate to new screen with received data
      if (mounted) {

         Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => PickupScreen(
              deliveryId: deliveryId,
              driver: driver as Map<String, dynamic>,
              otp: payload['otp'] as String?,
              pickup: payload['pickup'] as Map<String, dynamic>?,
              dropoff: payload['dropoff'] as Map<String, dynamic>?,
            ),
          ),
        );

      }

    } catch (e) {
      log('⚠️ Error parsing driver data: $e');
      log('Payload type: ${payload.runtimeType}');
    }
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
      socket!.off('user:driver_assigned');
      socket!.off('receive_message');
      socket!.clearListeners(); // ✅ removes all listeners
      socket!.disconnect();
      socket!.dispose();  // Better than close()
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Color(0xFFFFFFFF),
            shape: CircleBorder(),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: Icon(Icons.arrow_back_ios, color: Color(0xFF1D3557)),
            ),
          ),
        ),
        title: Text(
          "Select Vehical",
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
      body: distanceProviderState.when(
        data: (snp) {
          final name = snp.data[0].name;
          final phon = snp.data[0].mobNo;
          final pickupAddress = snp.data[0].origName;
          final dropAddress = snp.data[0].destName;
          ///////////////////////////// My Design ==================
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(top: 10.h, left: 20.w, right: 20.w),
                padding: EdgeInsets.only(
                  left: 12.w,
                  right: 12.w,
                  top: 18.h,
                  bottom: 18.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 2),
                      blurRadius: 3,
                      spreadRadius: 2,
                      color: Color.fromARGB(28, 0, 0, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.circle, size: 12.sp, color: Colors.green),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "${name} ·",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " ${phon}",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 13.sp,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                // "60 Feet Rd, Sanjay Nagar, Jagann...",
                                pickupAddress,
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14.sp, color: Colors.red),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "${name} ·",

                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " ${phon}",

                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 13.sp,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                dropAddress,
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
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
                    padding: EdgeInsets.zero,
                    children: [
                      SizedBox(height: 8.h),
                      Center(
                        child: Container(
                          width: 50.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Center(
                        child: Text(
                          "Choose a Trip",
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000),
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Container(
                        width: double.infinity,
                        height: 170.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Color(0xFF000000),
                            width: 3,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.h),
                            Center(
                              child: Image.network(
                                // "assets/car.png",
                                snp.data[selectIndex].image,
                                width: 110.w,
                                height: 70.h,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    "assets/car.png",
                                    width: 106.w,
                                    height: 60.h,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 18.w),
                                  child: Text(
                                    //Delivery Go
                                    "${snp.data[selectIndex].vehicleType}",
                                    style: GoogleFonts.inter(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xfF000000),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 18.w),
                                  child: Text(
                                    // "₹170.71",
                                    "₹${snp.data[selectIndex].price}",
                                    style: GoogleFonts.inter(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xfF000000),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 18.w),
                              child: Row(
                                children: [
                                  Text(
                                    "8:46pm",
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF000000),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  SizedBox(width: 6.w),
                                  CircleAvatar(
                                    radius: 4.r,
                                    backgroundColor: Color(0xFFD9D9D9),
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    "4 min away",
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF000000),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Container(
                              margin: EdgeInsets.only(left: 18.w),
                              width: 65.w,
                              height: 22.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.r),
                                color: const Color(0xFF3B6CE9),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bolt,
                                    color: Colors.white,
                                    size: 16.sp,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    "Faster",
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 25.h),
                      ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snp.data.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectIndex = index;
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: 20.h,
                                left: 5.w,
                                right: 5.w,
                              ),
                              child: Container(
                                padding: EdgeInsets.only(
                                  left: 10.w,
                                  right: 12.w,
                                  top: 10.h,
                                  bottom: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: selectIndex == index
                                        ? Color.fromARGB(127, 0, 0, 0)
                                        : Colors.transparent,
                                    width: 1.w,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Image.network(
                                      // "assets/b.png",
                                      //selectTrip[index]["image"].toString(),
                                      snp.data[index].image,
                                      width: 50.w,
                                      height: 50.h,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          // "https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/624px-No-Image-Placeholder.svg.png",
                                          "assets/b.png",
                                          width: 50.w,
                                          height: 50.h,
                                          fit: BoxFit.contain,
                                        );
                                      },
                                    ),
                                    SizedBox(width: 10.w),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          //"Delivery Go",
                                          // selectTrip[index]['name'],
                                          snp.data[index].vehicleType,
                                          style: GoogleFonts.inter(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xff000000),
                                            letterSpacing: -1,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "8:46pm",
                                              style: GoogleFonts.inter(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFF000000),
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                            SizedBox(width: 6.w),
                                            CircleAvatar(
                                              radius: 3.r,
                                              backgroundColor: Color(
                                                0xFFD9D9D9,
                                              ),
                                            ),
                                            SizedBox(width: 6.w),
                                            Text(
                                              "4 min away",
                                              style: GoogleFonts.inter(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFF000000),
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          // "₹170.71",
                                          // selectTrip[index]['ammount'],
                                          "₹${snp.data[index].price}",
                                          style: GoogleFonts.inter(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xfF000000),
                                            letterSpacing: -1,
                                          ),
                                        ),
                                        if (index == 0 || index == 1)
                                          Text(
                                            //"₹188.71",
                                            selectTrip[index]['discount'],
                                            style: GoogleFonts.inter(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF6B6B6B),
                                              letterSpacing: 0,
                                              decoration:
                                              TextDecoration.lineThrough,
                                              decorationColor: Color(
                                                0xFF6B6B6B,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 15.h),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50.h),
                          backgroundColor: Color(0xFF006970),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onPressed: isBooking
                            ? null
                            : () async {
                          setState(() => isBooking = true);
                          try {
                            final selectedVehicle = snp.data[selectIndex];
                            final body = BookInstantDeliveryBodyModel(
                              vehicleTypeId:
                              selectedVehicle.vehicleTypeId,
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
                            final result = await ref
                                .read(bookDeliveryProvider.notifier)
                                .bookInstantDelivery(body);
                            // log('Booking Response: $result');  // Added logging
                            // Navigator.push(
                            //   context,
                            //   CupertinoPageRoute(
                            //     builder: (context) => PickupScreen(),
                            //   ),
                            // );
                            setState(() {
                              isBooking = false;
                            });
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
                                  borderRadius: BorderRadius.circular(
                                    15.r,
                                  ),
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
                      SizedBox(height: 10.h),
                    ],
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

// ✅ New Screen: DeliveryDetailsScreen
class DeliveryDetailsScreen extends StatelessWidget {
  final String deliveryId;
  final Map<String, dynamic> driver;
  final String? otp;
  final Map<String, dynamic>? pickup;
  final Map<String, dynamic>? dropoff;

  const DeliveryDetailsScreen({
    super.key,
    required this.deliveryId,
    required this.driver,
    this.otp,
    this.pickup,
    this.dropoff,
  });

  @override
  Widget build(BuildContext context) {
    final driverName = driver['name'] ?? 'Unknown Driver';
    final driverPhone = driver['phone'] ?? 'N/A';
    final driverId = driver['id'] ?? '';

    // Simple address formatting (extend if you have full address in payload)
    String pickupAddress = pickup != null
        ? 'Pickup: Lat ${pickup!['lat'] ?? ''}, Lng ${pickup!['long'] ?? ''}'
        : 'Pickup Location Not Available';
    String dropoffAddress = dropoff != null
        ? 'Dropoff: Lat ${dropoff!['lat'] ?? ''}, Lng ${dropoff!['long'] ?? ''}'
        : 'Dropoff Location Not Available';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1D3557)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Delivery #$deliveryId',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Info Card
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assigned Driver',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20.r,
                          backgroundColor: Colors.grey[300],
                          child: Text(
                            driverName.isNotEmpty ? driverName[0].toUpperCase() : '?',
                            style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driverName,
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                driverPhone,
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // OTP Card
            if (otp != null)
              Card(
                elevation: 4,
                color: Colors.blue[50],
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline, color: Colors.blue[700], size: 24.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'OTP for Pickup Verification',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              otp!,
                              style: GoogleFonts.inter(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 16.h),

            // Pickup Location
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.green, size: 24.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        pickupAddress,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Dropoff Location
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Icon(Icons.flag, color: Colors.red, size: 24.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        dropoffAddress,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // Status or Next Action Button (e.g., Track Delivery)
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50.h),
                  backgroundColor: Color(0xFF006970),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onPressed: () {
                  // Navigate to tracking screen or handle next step
                  Fluttertoast.showToast(msg: 'Tracking Delivery...');

                },
                child: Text(
                  'Track Delivery',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}