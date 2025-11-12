import 'dart:async';
import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/instantDelivery.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/orderList.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/payment.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/profile.screen.dart';
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
import 'package:intl/intl.dart';
import '../data/controller/getDeliveryHistoryController.dart';
import 'DetailPage.dart';
import 'Newscreen.dart';

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
    {"image": "assets/b.png", "name": "Express Bike", "title": "Quick Parcels"},

    {
      "image": "assets/SvgImage/truck.svg",
      "name": "small Box truck",
      "title": "Local & Medium",
    },
    {
      "image": "assets/SvgImage/truc.svg",
      "name": "Heavy Trucks",
      "title": "Full Load",
    },

    {
      "image": "assets/t.png",
      "name": "Auto Tempo",
      "title": "Choose from Our Fleet",
    },
    {
      "image": "assets/SvgImage/packer.svg",
      "name": "Packer &  Mover",
      "title": "Home Shifting",
    },
    {
      "image": "assets/SvgImage/india.svg",
      "name": "All India Parcel",
      "title": "Choose from Our Fleet",
    },
  ];
  final List<Color> cardColors = [
    Color(0xFF87BEB5),
    Color(0xFFDEC9A9),
    Color(0xFF8FBAD1),
    Color(0xFF87BEB5),
    Color(0xFFDEC9A9),
    Color(0xFF87BEB5),
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
  String? userId;
  late IO.Socket socket;
  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    userId = box.get("id")?.toString(); // fetch once
    _connectSocket();
    // Yeh line add karo - har baar screen aane par API refresh ho jayega
    WidgetsBinding.instance.addPostFrameCallback((_) {

      ref.invalidate(getDeliveryHistoryController); // ya refresh()
      _disconnectSocket();
      _connectSocket();
      // ya
      // ref.refresh(getDeliveryHistoryController);
    });
  }

  /// Disconnect and clean up old socket
  void _disconnectSocket() {
    if (socket != null) {
      if (socket!.connected) {
        socket!.disconnect();
      }
      socket!.clearListeners(); // Remove all listeners to prevent duplicates
      socket!.dispose();

    }

    if (mounted) {
      setState(() => isSocketConnected = false);
    }
    print('🔌 Old socket disconnected and cleaned');
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Har baar jab screen visible ho (route active ho), API call karo
    final route = ModalRoute.of(context);
    if (route is PageRoute && route.isCurrent) {
      // Sirf jab yeh screen active ho
      ref.invalidate(getDeliveryHistoryController);
      _disconnectSocket();
      _connectSocket();
      // ya ref.refresh(getDeliveryHistoryController);
    }
  }

  // -------------------------------------------------
  // SOCKET CONNECTION (centralised in HomeScreen)
  // -------------------------------------------------
  void _connectSocket() {
    const socketUrl = 'http://192.168.1.43:4567';
    // const socketUrl = 'https://weloads.com';

    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket', 'polling'],
      'autoConnect': false,
    });

    // Log everything for debugging
    socket.onAny((event, data) => log("SOCKET EVENT: $event → $data"));

    socket.connect();

    socket.onConnect((_) {
      log('✅ Socket connected');
      Fluttertoast.showToast(msg: "Socket connected");
      setState(() => isSocketConnected = true);

      // Register the customer once connected
      if (userId != null) {
        socket.emitWithAck('registerCustomer', {
          'userId': userId,
          'role': 'customer',
        }, ack: (ack) => log('🔐 Registration ACK: $ack'));
      } else {
        log('❌ No userId for registration!');
      }

      // You can start location streaming here if you need it on HomeScreen
      // startLocationStream();
    });

    socket.onDisconnect((_) {
      log('❌ Socket disconnected');
      Fluttertoast.showToast(msg: "Socket disconnected");
      setState(() => isSocketConnected = false);
    });

    socket.onReconnect((data) {
      log('🔄 Socket reconnected');
      setState(() => isSocketConnected = true);
      // Re-register on reconnect
      if (userId != null) {
        socket.emit('join:user', {'userId': userId});
      }
    });

    socket.onReconnectError((err) => log('❌ Reconnect error: $err'));
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



  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "assigned":
        return const Color(0xFFE3F2FD); // light blue
      case "ongoing":
        return const Color(0xFF7DCF4A); // light blue
      case "not_assigned":
        return const Color(0xFFFFEBEE); // light red
      case "completed":
        return const Color(0xFFE8F5E9); // light green
      case "pending":
        return const Color(0xFFFFF4C7); // light yellow
      default:
        return const Color(0xFFE0E0E0); // gray fallback
    }
  }
  Color _getStatusTextColor(String? status) {
    switch (status?.toLowerCase()) {
      case "assigned":
        return const Color(0xFF0D47A1); // dark blue
      case "not_assigned":
        return const Color(0xFFC62828); // dark red
      case "completed":
        return const Color(0xFF2E7D32); // dark green
      case "pending":
        return const Color(0xFF7E6604); // dark yellow-brown
      default:
        return const Color(0xFF424242); // dark gray
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyProvier = ref.watch(getDeliveryHistoryController);
    // 🔄 Show loader while checking
    if (_isCheckingLocation) {
      return Scaffold(
        backgroundColor: const Color(0xFF006970),
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
        backgroundColor: const Color(0xFF006970),
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
          ?

      SingleChildScrollView(
        child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 200.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        topRight: Radius.circular(20.r),
                      ),
                      color: Color(0xFF006970),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 50.h),
                        Text(
                          "Hey ${box.get("firstName")}",
                          style: GoogleFonts.inter(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "ready to book your next delivery?",
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(180.w, 50.h),
                            backgroundColor: Colors.amber,
                          ),
                          onPressed: () {


                            Navigator.push(context, MaterialPageRoute(builder: (context)=>InstantDeliveryScreen(socket)));


                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //
                            //         InstantDeliveryScreen(),
                            //   ),
                            // );

                          },
                          child: Text(
                            "Book",
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      "Choose the write vehical for your delivery - fast,reliable & affordable!",
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006970),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Padding(
                    padding: EdgeInsets.only(left: 15.w, right: 15.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        delivery("Local"),
                        delivery("City"),
                        delivery("Nationwide"),
                        delivery("Home Shifting"),
                      ],
                    ),
                  ),



                  SizedBox(height: 20.h),
                  // Expanded(
                  //   child:
                    Padding(
                      padding: EdgeInsets.only(
                        left: 15.w,
                        right: 15.w,
                        bottom: 10.h,
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        itemCount: myList.length,
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20.w,
                          mainAxisSpacing: 20.w,
                          childAspectRatio: 0.91,
                        ),
                        itemBuilder: (context, index) {


                          return InkWell(
                            onTap: () {
                              if (index == 4 || index == 5) {
                                Fluttertoast.showToast(msg: "Comming Soon");
                              } else {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => InstantDeliveryScreen(socket),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width: 160.w,
                              height: 185.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Card(
                                color: cardColors[index % cardColors.length],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
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
                                              width: 80.w,
                                              height: 80.h,
                                            )
                                          : Image.asset(
                                              myList[index]['image'],
                                              width: 80.w,
                                              height: 80.h,
                                            ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: 9.w,
                                        top: 4.h,
                                      ),
                                      child: Text(
                                        // "Trucks",
                                        myList[index]['name'].toString(),
                                        style: GoogleFonts.inter(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF000000),
                                          letterSpacing: -1,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 9.w),
                                      child: Text(
                                        //  "Choose from Our Fleet",
                                        myList[index]['title'].toString(),
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
                            ),
                          );


                        },
                      ),
                    ),
                  // ),
                  SizedBox(height: 20.h,),
                  historyProvier.when(
                    data: (history) {
                      if (history.data.deliveries.isEmpty) {
                        return Center(
                          child: Text(
                            "No History Available",
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                            ),
                          ),
                        );
                      }
                      DateTime date = DateTime.fromMillisecondsSinceEpoch(
                        1761395019837,
                      );
                      String formattedDate = DateFormat(
                        "dd MMMM yyyy, h:mma",
                      ).format(date);
                      return
                        // Expanded(
                        // child:
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: history.data.deliveries.length,
                          itemBuilder: (context, index) {
                            return
                              history.data.deliveries[index].status=="ongoing"?
                              GestureDetector(
                                onTap: (){

                                  history.data.deliveries[index].status=="assigned" ||    history.data.deliveries[index].status=="ongoing"?

                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>

                                      PickupScreenNotification(
                                          deliveryId: history.data.deliveries[index].id
                                      )))

                                      :   Navigator.push(context, MaterialPageRoute(builder: (context)=>

                                      RequestDetailsPage(
                                          deliveryId: history.data.deliveries[index].id
                                      )));
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 15.h,
                                    left: 25.w,
                                    right: 25.w,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            // "ORDB1234",
                                            history.data.deliveries[index].id,
                                            style: GoogleFonts.inter(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF0C341F),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Receipient: ${history.data.deliveries[index].name ?? "Unknow"}",
                                                style: GoogleFonts.inter(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xFF545454),
                                                ),
                                              ),
                                              Spacer(),
                                              // if (index == 0)
                                              Container(
                                                padding: EdgeInsets.only(
                                                  left: 6.w,
                                                  right: 6.w,
                                                  top: 2.h,
                                                  bottom: 2.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(
                                                    3.r,
                                                  ),
                                                  // color: Color(0xFFFFF4C7),
                                                  color: _getStatusColor(
                                                    history.data.deliveries[index].status,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    // "In progress",
                                                    history.data.deliveries[index].status
                                                        .toString(),
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12.sp,
                                                      fontWeight: FontWeight.w500,
                                                      // color: Color(0xFF7E6604),
                                                      color: _getStatusTextColor(
                                                        history
                                                            .data
                                                            .deliveries[index]
                                                            .status,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10.h),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 35.w,
                                            height: 35.h,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5.r),
                                              color: Color(0xFFF7F7F7),
                                            ),
                                            child: Center(
                                              child: SvgPicture.asset(
                                                "assets/SvgImage/bikess.svg",
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      size: 16.sp,
                                                      color: Color(0xFF27794D),
                                                    ),
                                                    SizedBox(width: 5.w),
                                                    Text(
                                                      "Drop off",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 12.sp,
                                                        fontWeight: FontWeight.w400,
                                                        color: Color(0xFF545454),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 3.w,
                                                    top: 2.h,
                                                  ),
                                                  child: Text(
                                                    // "21b, Karimu Kotun Street, Victoria Island",
                                                    history
                                                        .data
                                                        .deliveries[index]
                                                        .dropoff
                                                        .name
                                                        .toString(),
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w400,
                                                      color: Color(0xFF0C341F),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 2.h),
                                                Text(
                                                  //2 January 2020, 2:43pm",
                                                  DateFormat("dd MMMM yyyy, h:mma")
                                                      .format(
                                                    DateTime.fromMillisecondsSinceEpoch(
                                                      history
                                                          .data
                                                          .deliveries[index]
                                                          .createdAt,
                                                    ),
                                                  )
                                                      .toLowerCase(),
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFF545454),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 12.h),
                                      Divider(color: Color(0xFFDCE8E9)),
                                    ],
                                  ),
                                ),
                              ):SizedBox();
                          },
                        );
                      // );
                    },
                    error: (error, stackTrace) {
                      log(stackTrace.toString());
                      return Center(child: Text(error.toString()));
                    },
                    loading: () => Center(child: CircularProgressIndicator()),
                  ),
                  SizedBox(height: 40.h,),
                ],
              ),
      )

          : selectIndex == 1
          ? OrderListScreen()
          : selectIndex == 2
          ? PaymentScreen()
          : ProfileScreen(socket),
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

  Widget delivery(String name) {
    return Container(
      padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 8.h, bottom: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: Color(0xFFF3F7F5),
      ),
      child: Text(
        name,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: Color(0xFF006970),
        ),
      ),
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
