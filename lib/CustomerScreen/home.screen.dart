import 'dart:async';
import 'dart:developer';
import 'package:another_stepper/dto/stepper_data.dart';
import 'package:another_stepper/widgets/another_stepper.dart';
import 'package:delivery_mvp_app/CustomerScreen/instantDelivery.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/map.page.dart';
import 'package:delivery_mvp_app/CustomerScreen/orderList.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/packerMover.page.dart';
import 'package:delivery_mvp_app/CustomerScreen/payment.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/profile.screen.dart';
import 'package:delivery_mvp_app/data/controller/getProfileController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

var box = Hive.box("folder");
var id = box.get("id");

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int selectIndex = 0;
  List<Map<String, dynamic>> myList = [
    {
      "image": "assets/SvgImage/truc.svg",
      "name": "Trucks",
      "title": "Choose from Our Fleet",
    },
    {
      "image": "assets/SvgImage/truck.svg",
      "name": "small truck",
      "title": "For Smaller Good",
    },
    {
      "image": "assets/b.png",
      "name": "Bike",
      //"title": "Choose from Our Fleet",
    },
    {
      "image": "assets/t.png",
      "name": "Auto Tempo",
      //"title": "Choose from Our Fleet",
    },
    {
      "image": "assets/SvgImage/packer.svg",
      "name": "Packer &  Mover",
      //"title": "Choose from Our Fleet",
    },
    {
      "image": "assets/SvgImage/india.svg",
      "name": "All India Parcel",
      // "title": "Choose from Our Fleet",
    },
  ];

  int activeStep = 2;
  String? currentAddress;
  bool isSocketConnected = false;
  bool _locationEnabled = false;
  Position? _currentPosition;
  StreamSubscription<Position>? _locationSubscription;
  Map<String, dynamic>? assignedDriver;
  String receivedMessage = "";
  final List<Map<String, dynamic>> messages = [];
  bool _isCheckingLocation = true;

  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    setState(() {
      _isCheckingLocation = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationDialog(
        'Location services are disabled. Please enable them.',
      );
      setState(() => _isCheckingLocation = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showLocationDialog('Location permission denied.');
        setState(() => _isCheckingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showLocationDialog(
        'Location permission denied forever. Please enable in app settings.',
      );
      setState(() => _isCheckingLocation = false);
      return;
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _updateAddress();
      setState(() {
        _locationEnabled = true;
        _isCheckingLocation = false;
      });

      // Start listening for location updates
      startLocationStream();
    } catch (e) {
      log('Error getting location: $e');
      _showLocationDialog('Failed to get location. Please try again.');
      setState(() => _isCheckingLocation = false);
    }
  }

  void _showLocationDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkLocationPermission();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateAddress() async {
    if (_currentPosition == null) return;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          currentAddress =
              "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
        });
      } else {
        setState(() {
          currentAddress =
              "${_currentPosition!.latitude}, ${_currentPosition!.longitude}";
        });
      }
    } catch (e) {
      log('Error updating address: $e');
      setState(() {
        currentAddress =
            "${_currentPosition!.latitude}, ${_currentPosition!.longitude}";
      });
    }
  }

  void startLocationStream() {
    _locationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          log(
            "📍 Updated position: ${position.latitude}, ${position.longitude}",
          );
          setState(() {
            _currentPosition = position;
          });
          _updateAddress();
        });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  //////////////////////////////////////////////////////////////////////

  // Future<void> checkLocationPermission() async {
  //   setState(() {
  //     _isCheckingLocation = true; // 👈 start loading
  //   });
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     _showLocationDialog(
  //       'Location services are disabled. Please enable them.',
  //     );
  //     setState(() => _isCheckingLocation = false);
  //     return;
  //   }

  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       _showLocationDialog('Location permission denied.');
  //       setState(() => _isCheckingLocation = false);
  //       return;
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     _showLocationDialog(
  //       'Location permission denied forever. Please enable in app settings.',
  //     );
  //     setState(() => _isCheckingLocation = false);
  //     return;
  //   }

  //   // Get initial position
  //   try {
  //     _currentPosition = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //     );
  //     await _updateAddress();
  //     setState(() {
  //       _locationEnabled = true;
  //       _isCheckingLocation = false;
  //     });

  //     // Connect socket after location is enabled
  //     _connectSocket();
  //   } catch (e) {
  //     log('Error getting location: $e');
  //     _showLocationDialog('Failed to get location. Please try again.');
  //     setState(() => _isCheckingLocation = false);
  //   }
  // }

  // void _showLocationDialog(String message) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Location Required'),
  //       content: Text(message),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             _checkLocationPermission();
  //           },
  //           child: const Text('Retry'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Future<void> _updateAddress() async {
  //   if (_currentPosition == null) return;
  //   try {
  //     List<Placemark> placemarks = await placemarkFromCoordinates(
  //       _currentPosition!.latitude,
  //       _currentPosition!.longitude,
  //     );
  //     if (placemarks.isNotEmpty) {
  //       Placemark place = placemarks[0];
  //       setState(() {
  //         currentAddress =
  //             "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
  //       });
  //     } else {
  //       setState(() {
  //         currentAddress =
  //             "${_currentPosition!.latitude}, ${_currentPosition!.longitude}";
  //       });
  //     }
  //   } catch (e) {
  //     log('Error updating address: $e');
  //     setState(() {
  //       currentAddress =
  //           "${_currentPosition!.latitude}, ${_currentPosition!.longitude}";
  //     });
  //   }
  // }

  // void updateUserLocation(double lat, double lon) {
  //   if (socket.connected && socket.id != null) {
  //     socket.emit('user:location_update', {
  //       'userId': id,
  //       'lat': lat,
  //       'lon': lon,
  //     });
  //     log('📤 Location sent → lat: $lat, lon: $lon');
  //   } else {
  //     log('⚠️ Socket not connected or no ID!');
  //   }
  // }

  // void listenForLiveUpdates() {
  //   socket.on('user:location_update', (data) {
  //     log('📥 Live location from server: $data');
  //     // data = { userId: "...", lat: 26.91, lon: 75.78 }
  //   });
  // }

  // void startLocationStream() {
  //   _locationSubscription =
  //       Geolocator.getPositionStream(
  //         locationSettings: const LocationSettings(
  //           accuracy: LocationAccuracy.high,
  //           distanceFilter: 10, // update every 10 meters
  //         ),
  //       ).listen((Position position) {
  //         updateUserLocation(position.latitude, position.longitude);
  //         setState(() {
  //           _currentPosition = position;
  //         });
  //         _updateAddress(); // Optional: update address on move
  //       });
  // }

  // void _connectSocket() {
  //   //const socketUrl = 'http://192.168.1.43:4567'; // Change to your backend URL
  //   const socketUrl = 'https://weloads.com';

  //   socket = IO.io(socketUrl, <String, dynamic>{
  //     'transports': ['websocket'],
  //     'autoConnect': false,
  //   });

  //   socket.connect();
  //   socket.onConnect((data) {
  //     if (!mounted) return;
  //     log('Socket connected');
  //     Fluttertoast.showToast(msg: "Socket connected");
  //     socket.on('user:driver_assigned', _handleAssigned);
  //     socket.on('receive_message', _handleReceivedMessage);
  //     listenForLiveUpdates();
  //     if (mounted) {
  //       setState(() {
  //         isSocketConnected = true;
  //       });
  //       // Start location stream only after socket is connected
  //       startLocationStream();
  //     }
  //   });

  //   socket.onDisconnect((data) {
  //     if (!mounted) return;
  //     setState(() {
  //       isSocketConnected = false;
  //     });
  //     log('Socket disconnected');
  //     Fluttertoast.showToast(msg: "Socket disconnected");
  //   });

  //   socket.onConnectError((data) {
  //     log('⚠️ Connection Error: $data');
  //   });
  // }

  // void _handleAssigned(dynamic data) {
  //   if (!mounted) return;
  //   log(' Driver Assigned: $data');

  //   final driverName = data['name'] ?? 'Unknown';
  //   final driverPhone = data['phone'] ?? 'N/A';
  //   log(driverName);
  //   log(driverPhone);

  //   Fluttertoast.showToast(
  //     msg: "Driver Assigned: $driverName ($driverPhone)",
  //     toastLength: Toast.LENGTH_LONG,
  //   );

  //   setState(() {
  //     assignedDriver = data;
  //   });
  // }

  // void _handleReceivedMessage(dynamic data) {
  //   if (!mounted) return;

  //   log('📩 Message received: $data');

  //   final messageText = data is Map && data.containsKey('message')
  //       ? data['message']
  //       : data.toString();

  //   setState(() {
  //     messages.add({'text': messageText, 'isMine': false});
  //   });
  // }

  // @override
  // void dispose() {
  //   _locationSubscription?.cancel();
  //   socket.off('receive_message');
  //   socket.off('user:driver_assigned');
  //   socket.off('connect');
  //   socket.off('disconnect');
  //   socket.off('user:location_update');
  //   socket.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    // 🔄 Show loader while checking
    if (_isCheckingLocation) {
      return Scaffold(
        backgroundColor: const Color(0xFF82ECF3),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white, strokeWidth: 4),
              SizedBox(height: 20.h),
              Text(
                'Checking location permission...',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Don't show homepage until location is enabled
    if (!_locationEnabled) {
      return Scaffold(
        backgroundColor: const Color(0xFF82ECF3),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 100.sp, color: Colors.white),
              SizedBox(height: 20.h),
              Text(
                'Enable Location',
                style: GoogleFonts.inter(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Please enable location services to continue',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30.h),
              ElevatedButton(
                onPressed: _checkLocationPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF006970),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.w,
                    vertical: 15.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                child: Text(
                  'Enable Location',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: selectIndex == 0
          ? SingleChildScrollView(
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: MediaQuery.of(context).size.height / 1,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.50, -0.00),
                          end: Alignment(0.50, 1.00),
                          colors: [const Color(0xFF82ECF3), Colors.white],
                        ),
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    "assets/SvgImage/bg.svg",
                    //width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 21.w,
                      right: 21.w,
                      top: 50.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () async {
                                final selectedAddress = await Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => MapPage(),
                                  ),
                                );

                                if (selectedAddress != null && mounted) {
                                  setState(() {
                                    currentAddress = selectedAddress;
                                  });
                                }
                              },
                              child: Container(
                                width: 40.w,
                                height: 40.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: Color(0xFF006970),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            InkWell(
                              onTap: () async {
                                final selectedAddress = await Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => MapPage(),
                                  ),
                                );

                                if (selectedAddress != null && mounted) {
                                  setState(() {
                                    currentAddress = selectedAddress;
                                  });
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentAddress ?? "Fetching location...",
                                    style: GoogleFonts.inter(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                  Text(
                                    "Tap to change",
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF086E86),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Container(
                              width: 40.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Icon(
                                Icons.notifications_none,
                                color: Color(0xFF242126),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        TextField(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(
                              left: 15.w,
                              right: 15.w,
                              top: 10.h,
                              bottom: 10.h,
                            ),
                            filled: true,
                            fillColor: Color(0xFFFFFFFF),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40.r),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40.r),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Enter your tracking number",
                            hintStyle: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFCCCCCC),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Color(0xFF2490A9),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: Color.fromARGB(51, 237, 237, 237),
                              width: 1.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 15,
                                spreadRadius: 0,
                                offset: Offset(0, 0),
                                color: Color.fromARGB(15, 118, 118, 118),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 24.w,
                              right: 24.w,
                              top: 16.h,
                              bottom: 16.h,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                cardbuild(
                                  "assets/SvgImage/chec.svg",
                                  "Check Rate",
                                ),
                                cardbuild(
                                  "assets/SvgImage/picku.svg",
                                  "Pick Up",
                                ),
                                cardbuild(
                                  "assets/SvgImage/dro.svg",
                                  "Drop Off",
                                ),
                                cardbuild("assets/SvgImage/his.svg", "History"),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 28.h),
                        GridView.builder(
                          itemCount: myList.length,
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 20.w,
                                mainAxisSpacing: 20.w,
                                childAspectRatio: 0.80,
                              ),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                if (index == 4) {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => PackerMoverPage(),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) =>
                                          InstantDeliveryScreen(),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                width: 158.w,
                                height: 181.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(color: Color(0xFFE8E8E8)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 30.h),
                                    Center(
                                      child:
                                          myList[index]['image']
                                              .toString()
                                              .endsWith(".svg")
                                          ? SvgPicture.asset(
                                              myList[index]['image'],
                                            )
                                          : Image.asset(myList[index]['image']),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 9.w,
                                        top: 4.h,
                                      ),
                                      child: Text(
                                        // "Trucks",
                                        myList[index]['name'],
                                        style: GoogleFonts.inter(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF000000),
                                          letterSpacing: -1,
                                        ),
                                      ),
                                    ),
                                    if (index == 0 || index == 1)
                                      Padding(
                                        padding: EdgeInsets.only(left: 9.w),
                                        child: Text(
                                          //  "Choose from Our Fleet",
                                          myList[index]['title'],
                                          style: GoogleFonts.inter(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF000000),
                                            letterSpacing: -1,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Text(
                              "Current Shipment",
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF353535),
                              ),
                            ),
                            Spacer(),
                            Text(
                              "View All",
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2490A9),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 18.h),
                        Container(
                          padding: EdgeInsets.only(
                            // left: 16.w,
                            // right: 16.w,
                            top: 14.h,
                            bottom: 14.h,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: Color.fromARGB(153, 237, 237, 237),
                            ),
                            boxShadow: [
                              BoxShadow(
                                spreadRadius: 0,
                                blurRadius: 17.39,
                                offset: Offset(0, 0),
                                color: Color.fromARGB(15, 118, 118, 118),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 16.w,
                                  right: 16.w,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40.w,
                                      height: 40.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFFFFFFF),
                                        border: Border.all(
                                          color: Color.fromARGB(
                                            102,
                                            237,
                                            237,
                                            237,
                                          ),
                                        ),
                                      ),
                                      child: SvgPicture.asset(
                                        "assets/SvgImage/id.svg",
                                        width: 20.w,
                                        height: 20.h,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "#HWDSF776567DS",
                                          style: GoogleFonts.inter(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF353535),
                                          ),
                                        ),
                                        Text(
                                          "#On the way . 24 June",
                                          style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFFABABAB),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    IconButton(
                                      style: IconButton.styleFrom(
                                        minimumSize: Size(15.w, 30.h),
                                        padding: EdgeInsets.only(right: 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.arrow_forward_ios_outlined,
                                        color: Color(0xFF353535),
                                        size: 16.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 15.h),
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AnotherStepper(
                                      stepperList: [
                                        StepperData(
                                          iconWidget: const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF2490A9),
                                          ),
                                        ),
                                        StepperData(
                                          iconWidget: const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF2490A9),
                                          ),
                                        ),
                                        StepperData(
                                          iconWidget: const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF2490A9),
                                          ),
                                        ),
                                        StepperData(),
                                        StepperData(),
                                      ],
                                      stepperDirection: Axis.horizontal,
                                      activeBarColor: Color(0xFF2490A9),
                                      inActiveBarColor: Color(0xFFEDEDED),
                                      activeIndex: 2,
                                      barThickness: 2,
                                    ),
                                    SizedBox(height: 10.h),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 16.w,
                                        right: 16.w,
                                      ),
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "From",
                                                style: GoogleFonts.inter(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xFF2490A9),
                                                ),
                                              ),
                                              SizedBox(height: 1),
                                              Text(
                                                "Delhi, India",
                                                style: GoogleFonts.inter(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xFF353535),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                "To",
                                                style: GoogleFonts.inter(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xFF2490A9),
                                                ),
                                              ),
                                              SizedBox(height: 1),
                                              Text(
                                                "California, US",
                                                style: GoogleFonts.inter(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xFF353535),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Text(
                              "Recent Shipment",
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF353535),
                              ),
                            ),
                            Spacer(),
                            Text(
                              "View All",
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2490A9),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        Shipment(),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : selectIndex == 1
          ? OrderListScreen()
          : selectIndex == 2
          ? PaymentScreen()
          : ProfileScreen(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            selectIndex = value;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF006970),
        unselectedItemColor: Colors.grey,
        currentIndex: selectIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Order"),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_rounded),
            label: "Payment",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_sharp),
            label: "Account",
          ),
        ],
      ),
    );
  }

  Widget cardbuild(String image, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(image),
        SizedBox(height: 8.h),
        Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Color(0xFF353535),
          ),
        ),
      ],
    );
  }
}

class Shipment extends StatefulWidget {
  const Shipment({super.key});

  @override
  State<Shipment> createState() => _ShipmentState();
}

class _ShipmentState extends State<Shipment> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(top: 14.h),
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 14.h,
            bottom: 14.h,
          ),
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Color.fromARGB(153, 237, 237, 237)),
            boxShadow: [
              BoxShadow(
                spreadRadius: 0,
                blurRadius: 17.39,
                offset: Offset(0, 0),
                color: Color.fromARGB(15, 118, 118, 118),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFFFFF),
                  border: Border.all(color: Color.fromARGB(102, 237, 237, 237)),
                ),
                child: SvgPicture.asset(
                  "assets/SvgImage/id.svg",
                  width: 20.w,
                  height: 20.h,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "#HWDSF776567DS",
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF353535),
                    ),
                  ),
                  Text(
                    "#On the way . 24 June",
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFABABAB),
                    ),
                  ),
                ],
              ),
              Spacer(),
              IconButton(
                style: IconButton.styleFrom(
                  minimumSize: Size(15.w, 30.h),
                  padding: EdgeInsets.only(right: 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {},
                icon: Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Color(0xFF353535),
                  size: 16.sp,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
