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
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/adapters.dart';

class SelectTripScreen extends ConsumerStatefulWidget {
  // final GetDistanceBodyModel originalBody;
  const SelectTripScreen({super.key});

  @override
  ConsumerState<SelectTripScreen> createState() => _SelectTripScreenState();
}

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

  // bool isCheck = false;
  GoogleMapController? _mapController;
  LatLng? _currentLatlng;
  int selectIndex = 0;
  bool isBooking = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentLoacation();
  }

  Future<void> _getCurrentLoacation() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
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

    setState(() {
      _currentLatlng = LatLng(position.latitude, position.longitude);
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(_currentLatlng!));
  }

  @override
  Widget build(BuildContext context) {
    var box = Hive.box("folder");
    final distanceProviderState = ref.watch(getDistanceProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      // floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      // floatingActionButton: FloatingActionButton(
      //   mini: true,
      //   backgroundColor: Color(0xFFFFFFFF),
      //   shape: CircleBorder(),
      //   onPressed: () {
      //     Navigator.pop(context);
      //   },
      //   child: Padding(
      //     padding: EdgeInsets.only(left: 8.w),
      //     child: Icon(Icons.arrow_back_ios, color: Color(0xFF1D3557)),
      //   ),
      // ),
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
                margin: EdgeInsets.only(top: 15.h, left: 20.w, right: 20.w),
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
                                  await ref
                                      .read(bookDeliveryProvider.notifier)
                                      .bookInstantDelivery(body);
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => PickupScreen(),
                                    ),
                                  );
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
          // return _currentLatlng == null
          //     ? Center(child: CircularProgressIndicator())
          //     : Stack(
          //         children: [
          //           GoogleMap(
          //             initialCameraPosition: CameraPosition(
          //               target: _currentLatlng!,
          //               zoom: 15,
          //             ),
          //             onMapCreated: (controller) {
          //               _mapController = controller;
          //             },
          //             myLocationEnabled: true,
          //             myLocationButtonEnabled: true,
          //           ),
          //           DraggableScrollableSheet(
          //             initialChildSize:
          //                 0.80, // 🔹 Sheet shuru me 45% height lega
          //             minChildSize: 0.35, // 🔹 Sabse chhoti height
          //             maxChildSize: 0.8, // 🔹 Upar drag karke max kitna khule
          //             builder: (context, scrollController) {
          //               return Container(
          //                 padding: EdgeInsets.symmetric(horizontal: 16.w),
          //                 decoration: BoxDecoration(
          //                   color: Color(0xFFFFFFFF),
          //                   borderRadius: BorderRadius.only(
          //                     topLeft: Radius.circular(16.r),
          //                     topRight: Radius.circular(16.r),
          //                   ),
          //                   boxShadow: [
          //                     BoxShadow(
          //                       color: Colors.black12,
          //                       blurRadius: 10,
          //                       spreadRadius: 5,
          //                     ),
          //                   ],
          //                 ),
          //                 child: ListView(
          //                   padding: EdgeInsets.zero,
          //                   controller: scrollController,
          //                   children: [
          //                     SizedBox(height: 8.h),
          //                     Center(
          //                       child: Container(
          //                         width: 50.w,
          //                         height: 4.h,
          //                         decoration: BoxDecoration(
          //                           color: Colors.grey[300],
          //                           borderRadius: BorderRadius.circular(10.r),
          //                         ),
          //                       ),
          //                     ),
          //                     SizedBox(height: 8.h),
          //                     Center(
          //                       child: Text(
          //                         "Choose a Trip",
          //                         style: GoogleFonts.inter(
          //                           fontSize: 18.sp,
          //                           fontWeight: FontWeight.w600,
          //                           color: Color(0xFF000000),
          //                           letterSpacing: -1,
          //                         ),
          //                       ),
          //                     ),
          //                     SizedBox(height: 10.h),
          //                     Container(
          //                       width: double.infinity,
          //                       height: 170.h,
          //                       decoration: BoxDecoration(
          //                         borderRadius: BorderRadius.circular(20.r),
          //                         border: Border.all(
          //                           color: Color(0xFF000000),
          //                           width: 3,
          //                         ),
          //                       ),
          //                       child: Column(
          //                         crossAxisAlignment: CrossAxisAlignment.start,
          //                         children: [
          //                           SizedBox(height: 10.h),
          //                           Center(
          //                             child: Image.network(
          //                               // "assets/car.png",
          //                               snp.data[selectIndex].image,
          //                               width: 110.w,
          //                               height: 70.h,
          //                               fit: BoxFit.contain,
          //                               errorBuilder:
          //                                   (context, error, stackTrace) {
          //                                     return Image.asset(
          //                                       "assets/car.png",
          //                                       width: 106.w,
          //                                       height: 60.h,
          //                                       fit: BoxFit.cover,
          //                                     );
          //                                   },
          //                             ),
          //                           ),
          //                           Row(
          //                             mainAxisAlignment:
          //                                 MainAxisAlignment.spaceBetween,
          //                             children: [
          //                               Padding(
          //                                 padding: EdgeInsets.only(left: 18.w),
          //                                 child: Text(
          //                                   //Delivery Go
          //                                   "${snp.data[selectIndex].vehicleType}",
          //                                   style: GoogleFonts.inter(
          //                                     fontSize: 18.sp,
          //                                     fontWeight: FontWeight.w500,
          //                                     color: Color(0xfF000000),
          //                                     letterSpacing: -0.5,
          //                                   ),
          //                                 ),
          //                               ),
          //                               Padding(
          //                                 padding: EdgeInsets.only(right: 18.w),
          //                                 child: Text(
          //                                   // "₹170.71",
          //                                   "₹${snp.data[selectIndex].price}",
          //                                   style: GoogleFonts.inter(
          //                                     fontSize: 18.sp,
          //                                     fontWeight: FontWeight.w500,
          //                                     color: Color(0xfF000000),
          //                                     letterSpacing: -0.5,
          //                                   ),
          //                                 ),
          //                               ),
          //                             ],
          //                           ),
          //                           Padding(
          //                             padding: EdgeInsets.only(left: 18.w),
          //                             child: Row(
          //                               children: [
          //                                 Text(
          //                                   "8:46pm",
          //                                   style: GoogleFonts.inter(
          //                                     fontSize: 14.sp,
          //                                     fontWeight: FontWeight.w400,
          //                                     color: Color(0xFF000000),
          //                                     letterSpacing: 1,
          //                                   ),
          //                                 ),
          //                                 SizedBox(width: 6.w),
          //                                 CircleAvatar(
          //                                   radius: 4.r,
          //                                   backgroundColor: Color(0xFFD9D9D9),
          //                                 ),
          //                                 SizedBox(width: 6.w),
          //                                 Text(
          //                                   "4 min away",
          //                                   style: GoogleFonts.inter(
          //                                     fontSize: 14.sp,
          //                                     fontWeight: FontWeight.w400,
          //                                     color: Color(0xFF000000),
          //                                     letterSpacing: 1,
          //                                   ),
          //                                 ),
          //                               ],
          //                             ),
          //                           ),
          //                           SizedBox(height: 5.h),
          //                           Container(
          //                             margin: EdgeInsets.only(left: 18.w),
          //                             width: 65.w,
          //                             height: 22.h,
          //                             decoration: BoxDecoration(
          //                               borderRadius: BorderRadius.circular(
          //                                 4.r,
          //                               ),
          //                               color: const Color(0xFF3B6CE9),
          //                             ),
          //                             child: Row(
          //                               mainAxisAlignment:
          //                                   MainAxisAlignment.center,
          //                               crossAxisAlignment:
          //                                   CrossAxisAlignment.center,
          //                               children: [
          //                                 Icon(
          //                                   Icons.bolt,
          //                                   color: Colors.white,
          //                                   size: 16.sp,
          //                                 ),
          //                                 SizedBox(width: 3.w),
          //                                 Text(
          //                                   "Faster",
          //                                   style: GoogleFonts.inter(
          //                                     fontSize: 12.sp,
          //                                     fontWeight: FontWeight.w500,
          //                                     color: Colors.white,
          //                                     letterSpacing: -0.5,
          //                                   ),
          //                                 ),
          //                               ],
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                     SizedBox(height: 25.h),
          //                     ListView.builder(
          //                       padding: EdgeInsets.zero,
          //                       physics: const NeverScrollableScrollPhysics(),
          //                       shrinkWrap: true,
          //                       itemCount: snp.data.length,
          //                       itemBuilder: (context, index) {
          //                         return InkWell(
          //                           onTap: () {
          //                             setState(() {
          //                               selectIndex = index;
          //                             });
          //                           },
          //                           child: Padding(
          //                             padding: EdgeInsets.only(
          //                               bottom: 20.h,
          //                               left: 5.w,
          //                               right: 5.w,
          //                             ),
          //                             child: Container(
          //                               padding: EdgeInsets.only(
          //                                 left: 10.w,
          //                                 right: 12.w,
          //                                 top: 10.h,
          //                                 bottom: 10.h,
          //                               ),
          //                               decoration: BoxDecoration(
          //                                 borderRadius: BorderRadius.circular(
          //                                   10.r,
          //                                 ),
          //                                 border: Border.all(
          //                                   color: selectIndex == index
          //                                       ? Color.fromARGB(127, 0, 0, 0)
          //                                       : Colors.transparent,
          //                                   width: 1.w,
          //                                 ),
          //                               ),
          //                               child: Row(
          //                                 children: [
          //                                   Image.network(
          //                                     // "assets/b.png",
          //                                     //selectTrip[index]["image"].toString(),
          //                                     snp.data[index].image,
          //                                     width: 50.w,
          //                                     height: 50.h,
          //                                     fit: BoxFit.contain,
          //                                     errorBuilder:
          //                                         (context, error, stackTrace) {
          //                                           return Image.asset(
          //                                             // "https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/624px-No-Image-Placeholder.svg.png",
          //                                             "assets/b.png",
          //                                             width: 50.w,
          //                                             height: 50.h,
          //                                             fit: BoxFit.contain,
          //                                           );
          //                                         },
          //                                   ),
          //                                   SizedBox(width: 10.w),
          //                                   Column(
          //                                     crossAxisAlignment:
          //                                         CrossAxisAlignment.start,
          //                                     children: [
          //                                       Text(
          //                                         //"Delivery Go",
          //                                         // selectTrip[index]['name'],
          //                                         snp.data[index].vehicleType,
          //                                         style: GoogleFonts.inter(
          //                                           fontSize: 18.sp,
          //                                           fontWeight: FontWeight.w400,
          //                                           color: Color(0xff000000),
          //                                           letterSpacing: -1,
          //                                         ),
          //                                       ),
          //                                       Row(
          //                                         children: [
          //                                           Text(
          //                                             "8:46pm",
          //                                             style: GoogleFonts.inter(
          //                                               fontSize: 14.sp,
          //                                               fontWeight:
          //                                                   FontWeight.w400,
          //                                               color: Color(
          //                                                 0xFF000000,
          //                                               ),
          //                                               letterSpacing: -0.5,
          //                                             ),
          //                                           ),
          //                                           SizedBox(width: 6.w),
          //                                           CircleAvatar(
          //                                             radius: 3.r,
          //                                             backgroundColor: Color(
          //                                               0xFFD9D9D9,
          //                                             ),
          //                                           ),
          //                                           SizedBox(width: 6.w),
          //                                           Text(
          //                                             "4 min away",
          //                                             style: GoogleFonts.inter(
          //                                               fontSize: 14.sp,
          //                                               fontWeight:
          //                                                   FontWeight.w400,
          //                                               color: Color(
          //                                                 0xFF000000,
          //                                               ),
          //                                               letterSpacing: -0.5,
          //                                             ),
          //                                           ),
          //                                         ],
          //                                       ),
          //                                     ],
          //                                   ),
          //                                   Spacer(),
          //                                   Column(
          //                                     crossAxisAlignment:
          //                                         CrossAxisAlignment.start,
          //                                     children: [
          //                                       Text(
          //                                         // "₹170.71",
          //                                         // selectTrip[index]['ammount'],
          //                                         "₹${snp.data[index].price}",
          //                                         style: GoogleFonts.inter(
          //                                           fontSize: 18.sp,
          //                                           fontWeight: FontWeight.w500,
          //                                           color: Color(0xfF000000),
          //                                           letterSpacing: -1,
          //                                         ),
          //                                       ),
          //                                       if (index == 0 || index == 1)
          //                                         Text(
          //                                           //"₹188.71",
          //                                           selectTrip[index]['discount'],
          //                                           style: GoogleFonts.inter(
          //                                             fontSize: 14.sp,
          //                                             fontWeight:
          //                                                 FontWeight.w400,
          //                                             color: Color(0xFF6B6B6B),
          //                                             letterSpacing: 0,
          //                                             decoration: TextDecoration
          //                                                 .lineThrough,
          //                                             decorationColor: Color(
          //                                               0xFF6B6B6B,
          //                                             ),
          //                                           ),
          //                                         ),
          //                                     ],
          //                                   ),
          //                                 ],
          //                               ),
          //                             ),
          //                           ),
          //                         );
          //                       },
          //                     ),
          //                     // SizedBox(height: 16.h),
          //                     // InkWell(
          //                     //   onTap: () {
          //                     //     Navigator.push(
          //                     //       context,
          //                     //       CupertinoPageRoute(
          //                     //         builder: (context) =>
          //                     //             SelectPaymentScreen(),
          //                     //       ),
          //                     //     );
          //                     //   },
          //                     //   child: Container(
          //                     //     padding: EdgeInsets.only(
          //                     //       left: 15.w,
          //                     //       right: 15.w,
          //                     //       top: 6.h,
          //                     //       bottom: 6.h,
          //                     //     ),
          //                     //     decoration: BoxDecoration(
          //                     //       borderRadius: BorderRadius.circular(10.r),
          //                     //       border: Border.all(
          //                     //         color: Color.fromARGB(127, 0, 0, 0),
          //                     //         width: 1.w,
          //                     //       ),
          //                     //     ),
          //                     //     child: Row(
          //                     //       children: [
          //                     //         SvgPicture.asset("assets/SvgImage/v.svg"),
          //                     //         SizedBox(width: 8.w),
          //                     //         Column(
          //                     //           crossAxisAlignment:
          //                     //               CrossAxisAlignment.start,
          //                     //           children: [
          //                     //             Text(
          //                     //               "....8980",
          //                     //               style: GoogleFonts.inter(
          //                     //                 fontSize: 18.sp,
          //                     //                 fontWeight: FontWeight.w900,
          //                     //                 color: Colors.black,
          //                     //                 letterSpacing: -1,
          //                     //               ),
          //                     //             ),
          //                     //             Text(
          //                     //               "Shaikh niyo",
          //                     //               style: GoogleFonts.inter(
          //                     //                 fontSize: 14.sp,
          //                     //                 fontWeight: FontWeight.w500,
          //                     //                 color: Color.fromARGB(
          //                     //                   127,
          //                     //                   0,
          //                     //                   0,
          //                     //                   0,
          //                     //                 ),
          //                     //                 letterSpacing: -1,
          //                     //               ),
          //                     //             ),
          //                     //           ],
          //                     //         ),
          //                     //         Spacer(),
          //                     //         Container(
          //                     //           width: 1.w,
          //                     //           height: 40.h,
          //                     //           color: Color.fromARGB(127, 0, 0, 0),
          //                     //         ),
          //                     //         Spacer(),
          //                     //         SvgPicture.asset(
          //                     //           "assets/SvgImage/ed.svg",
          //                     //         ),
          //                     //         SizedBox(width: 8.w),
          //                     //         Text(
          //                     //           "Note",
          //                     //           style: GoogleFonts.inter(
          //                     //             fontSize: 16.sp,
          //                     //             fontWeight: FontWeight.w500,
          //                     //             color: Color(0xFF000000),
          //                     //             letterSpacing: -1,
          //                     //           ),
          //                     //         ),
          //                     //         Spacer(),
          //                     //         Container(
          //                     //           width: 1.w,
          //                     //           height: 40.h,
          //                     //           color: Color.fromARGB(127, 0, 0, 0),
          //                     //         ),
          //                     //         Spacer(),
          //                     //         SvgPicture.asset(
          //                     //           "assets/SvgImage/addpromo.svg",
          //                     //         ),
          //                     //         SizedBox(width: 8.w),
          //                     //         Text(
          //                     //           "Add Promo",
          //                     //           style: GoogleFonts.inter(
          //                     //             fontSize: 16.sp,
          //                     //             fontWeight: FontWeight.w500,
          //                     //             color: Color(0xFF0690AF),
          //                     //             letterSpacing: -1,
          //                     //           ),
          //                     //         ),
          //                     //       ],
          //                     //     ),
          //                     //   ),
          //                     // ),
          //                     // SizedBox(height: 16.h),
          //                     // Container(
          //                     //   padding: EdgeInsets.only(
          //                     //     left: 8.w,
          //                     //     right: 10.w,
          //                     //     top: 6.h,
          //                     //     bottom: 6.h,
          //                     //   ),
          //                     //   decoration: BoxDecoration(
          //                     //     borderRadius: BorderRadius.circular(10.r),
          //                     //     border: Border.all(
          //                     //       color: Color(0xFF000000),
          //                     //       width: 1.w,
          //                     //     ),
          //                     //   ),
          //                     //   child: Row(
          //                     //     children: [
          //                     //       Transform.scale(
          //                     //         scale: 1,
          //                     //         child: Container(
          //                     //           //color: Colors.amber,
          //                     //           height: 25.h,
          //                     //           width: 30.w,
          //                     //           child: Checkbox(
          //                     //             shape: CircleBorder(),
          //                     //             activeColor: Color(0xFF222222),
          //                     //             value: isCheck,
          //                     //             onChanged: (value) {
          //                     //               setState(() {
          //                     //                 isCheck = value!;
          //                     //               });
          //                     //             },
          //                     //           ),
          //                     //         ),
          //                     //       ),
          //                     //       Container(
          //                     //         margin: EdgeInsets.only(left: 10.w),
          //                     //         //color: Colors.amber,
          //                     //         width: 265.w,
          //                     //         child: Text.rich(
          //                     //           TextSpan(
          //                     //             children: [
          //                     //               TextSpan(
          //                     //                 text:
          //                     //                     "I confirm that I have read, consent and agree to the",
          //                     //                 style: GoogleFonts.inter(
          //                     //                   fontSize: 14.sp,
          //                     //                   fontWeight: FontWeight.w500,
          //                     //                   color: Colors.black,
          //                     //                   letterSpacing: -1,
          //                     //                 ),
          //                     //               ),
          //                     //               TextSpan(
          //                     //                 text: " Terms and Conditions",
          //                     //                 style: GoogleFonts.inter(
          //                     //                   fontSize: 14.sp,
          //                     //                   fontWeight: FontWeight.w500,
          //                     //                   color: Color(0xFF086E86),
          //                     //                   letterSpacing: -1,
          //                     //                 ),
          //                     //               ),
          //                     //             ],
          //                     //           ),
          //                     //         ),
          //                     //       ),
          //                     //     ],
          //                     //   ),
          //                     // ),
          //                     SizedBox(height: 15.h),
          //                     ElevatedButton(
          //                       style: ElevatedButton.styleFrom(
          //                         minimumSize: Size(double.infinity, 50.h),
          //                         backgroundColor: Color(0xFF006970),
          //                         shape: RoundedRectangleBorder(
          //                           borderRadius: BorderRadius.circular(10.r),
          //                         ),
          //                       ),
          //                       onPressed: isBooking
          //                           ? null
          //                           : () async {
          //                               // if (!isCheck) {
          //                               //   Fluttertoast.showToast(
          //                               //     msg: "Please check",
          //                               //   );
          //                               //   return;
          //                               // }
          //                               setState(() => isBooking = true);
          //                               try {
          //                                 final selectedVehicle =
          //                                     snp.data[selectIndex];
          //                                 final body = BookInstantDeliveryBodyModel(
          //                                   vehicleTypeId:
          //                                       selectedVehicle.vehicleTypeId,
          //                                   //selectedVehicle.vehicleType,
          //                                   price: double.parse(
          //                                     selectedVehicle.price,
          //                                   ).toInt(),
          //                                   //                                             price: (selectedVehicle.price.contains('.'))
          //                                   // ? double.parse(selectedVehicle.price).toInt()
          //                                   // : int.parse(selectedVehicle.price),
          //                                   isCopanCode: false,
          //                                   copanId: null.toString(),
          //                                   copanAmount: 0,
          //                                   coinAmount: 0,
          //                                   taxAmount: 18,
          //                                   userPayAmount: double.parse(
          //                                     selectedVehicle.price,
          //                                   ).toInt(),
          //                                   distance: selectedVehicle.distance,
          //                                   // mobNo: selectedVehicle.mobNo,
          //                                   mobNo: "98767655678",
          //                                   name: selectedVehicle.name,
          //                                   // origName: selectedVehicle.origName,
          //                                   // origLat: selectedVehicle.origLat,
          //                                   // origLon: selectedVehicle.origLon,
          //                                   origName: "jaipur",
          //                                   origLat: 26.9124,
          //                                   origLon: 75.7873,
          //                                   destName: selectedVehicle.destName,
          //                                   destLat: selectedVehicle.destLat,
          //                                   destLon: selectedVehicle.destLon,
          //                                   picUpType:
          //                                       selectedVehicle.picUpType,
          //                                 );
          //                                 await ref
          //                                     .read(
          //                                       bookDeliveryProvider.notifier,
          //                                     )
          //                                     .bookInstantDelivery(body);
          //                                 Navigator.push(
          //                                   context,
          //                                   CupertinoPageRoute(
          //                                     builder: (context) =>
          //                                         PickupScreen(),
          //                                   ),
          //                                 );
          //                                 setState(() {
          //                                   isBooking = false;
          //                                 });
          //                                 // final bookingState = ref.read(
          //                                 //   bookDeliveryProvider,
          //                                 // );
          //                                 // bookingState.when(
          //                                 //   data: (response) {
          //                                 //     if (!response.error) {
          //                                 //       Navigator.push(
          //                                 //         context,
          //                                 //         CupertinoPageRoute(
          //                                 //           builder: (context) =>
          //                                 //               PickupScreen(),
          //                                 //         ),
          //                                 //       );
          //                                 //       // Navigator.push(
          //                                 //       //   context,
          //                                 //       //   CupertinoPageRoute(
          //                                 //       //     builder: (context) =>
          //                                 //       //         MyOrderScreen(),
          //                                 //       //   ),
          //                                 //       // );
          //                                 //     } else {
          //                                 //       setState(() {
          //                                 //         isBooking = false;
          //                                 //       });
          //                                 //       ScaffoldMessenger.of(
          //                                 //         context,
          //                                 //       ).showSnackBar(
          //                                 //         SnackBar(
          //                                 //           content: Text(
          //                                 //             "failed: ${response.message}",
          //                                 //           ),
          //                                 //           behavior: SnackBarBehavior
          //                                 //               .floating,
          //                                 //           margin: EdgeInsets.only(
          //                                 //             left: 15.w,
          //                                 //             bottom: 15.h,
          //                                 //             right: 15.w,
          //                                 //           ),
          //                                 //           shape: RoundedRectangleBorder(
          //                                 //             borderRadius:
          //                                 //                 BorderRadius.circular(
          //                                 //                   15.r,
          //                                 //                 ),
          //                                 //           ),
          //                                 //           backgroundColor: Colors.red,
          //                                 //         ),
          //                                 //       );
          //                                 //     }
          //                                 //   },
          //                                 //   error: (error, stackTrace) =>
          //                                 //       SizedBox(),
          //                                 //   loading: () => SizedBox(),
          //                                 // );
          //                               } catch (e, st) {
          //                                 setState(() {
          //                                   isBooking = false;
          //                                 });
          //                                 log(
          //                                   "${e.toString()} / ${st.toString()}",
          //                                 );
          //                                 ScaffoldMessenger.of(
          //                                   context,
          //                                 ).showSnackBar(
          //                                   SnackBar(
          //                                     content: Text(
          //                                       "Booking failed: $e",
          //                                     ),
          //                                     behavior:
          //                                         SnackBarBehavior.floating,
          //                                     margin: EdgeInsets.only(
          //                                       left: 15.w,
          //                                       bottom: 15.h,
          //                                       right: 15.w,
          //                                     ),
          //                                     shape: RoundedRectangleBorder(
          //                                       borderRadius:
          //                                           BorderRadius.circular(15.r),
          //                                       side: BorderSide.none,
          //                                     ),
          //                                     backgroundColor: Colors.red,
          //                                   ),
          //                                 );
          //                               }
          //                             },
          //                       child: isBooking
          //                           ? Center(
          //                               child: SizedBox(
          //                                 width: 30.w,
          //                                 height: 30.h,
          //                                 child: CircularProgressIndicator(
          //                                   color: Colors.white,
          //                                   strokeWidth: 2.w,
          //                                 ),
          //                               ),
          //                             )
          //                           : Text(
          //                               "Book Now",
          //                               style: GoogleFonts.inter(
          //                                 fontSize: 16.sp,
          //                                 fontWeight: FontWeight.w400,
          //                                 color: Color(0xFFFFFFFF),
          //                               ),
          //                             ),
          //                     ),
          //                     SizedBox(height: 10.h),
          //                   ],
          //                 ),
          //               );
          //             },
          //           ),
          //         ],
          //       );
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

// import 'dart:developer';
// import 'package:delivery_mvp_app/CustomerScreen/MyOrderScreen.dart';
// import 'package:delivery_mvp_app/CustomerScreen/pickup.screen.dart';
// import 'package:delivery_mvp_app/CustomerScreen/selectPayment.screen.dart';
// import 'package:delivery_mvp_app/data/Model/bookInstantdeliveryBodyModel.dart';
// import 'package:delivery_mvp_app/data/Model/getDistanceBodyModel.dart';
// import 'package:delivery_mvp_app/data/controller/bookInstantDeliveryController.dart';
// import 'package:delivery_mvp_app/data/controller/getDistanceController.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:hive_flutter/adapters.dart';

// class SelectTripScreen extends ConsumerStatefulWidget {
//   const SelectTripScreen({super.key});

//   @override
//   ConsumerState<SelectTripScreen> createState() => _SelectTripScreenState();
// }

// class _SelectTripScreenState extends ConsumerState<SelectTripScreen> {
//   GoogleMapController? _mapController;
//   LatLng? _currentLatlng;
//   int selectIndex = 0;
//   bool isBooking = false;
//   bool isCheck = false;

//   Set<Marker> _markers = {}; // Map markers

//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }

//   Future<void> _getCurrentLocation() async {
//     LocationPermission permission = await Geolocator.checkPermission();

//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Location permission denied")),
//         );
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             "Location permission permanently denied. Please enable it from settings.",
//           ),
//         ),
//       );
//       return;
//     }

//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );

//     setState(() {
//       _currentLatlng = LatLng(position.latitude, position.longitude);
//     });
//   }

//   // Update markers on map
//   void _updateMarkers(List vehicles) {
//     _markers.clear();

//     if (_currentLatlng != null) {
//       // Current location marker
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('current_location'),
//           position: _currentLatlng!,
//           infoWindow: const InfoWindow(title: 'You are here'),
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//             BitmapDescriptor.hueAzure,
//           ),
//         ),
//       );

//       // All vehicle markers
//       for (int i = 0; i < vehicles.length; i++) {
//         final vehicle = vehicles[i];
//         _markers.add(
//           Marker(
//             markerId: MarkerId('vehicle_$i'),
//             position: LatLng(vehicle.origLat, vehicle.origLon),
//             infoWindow: InfoWindow(title: vehicle.vehicleType),
//             icon: BitmapDescriptor.defaultMarkerWithHue(
//               i == selectIndex
//                   ? BitmapDescriptor.hueRed
//                   : BitmapDescriptor.hueOrange,
//             ),
//           ),
//         );
//       }
//     }

//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     final distanceProviderState = ref.watch(getDistanceProvider);

//     return Scaffold(
//       floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.white,
//         shape: const CircleBorder(),
//         onPressed: () => Navigator.pop(context),
//         child: const Icon(Icons.arrow_back_ios, color: Color(0xFF1D3557)),
//       ),
//       body: distanceProviderState.when(
//         data: (vehicles) {
//           if (_currentLatlng != null) {
//             _updateMarkers(vehicles.data); // update map markers
//           }

//           return Stack(
//             children: [
//               _currentLatlng == null
//                   ? const Center(child: CircularProgressIndicator())
//                   : GoogleMap(
//                       initialCameraPosition: CameraPosition(
//                         target: _currentLatlng!,
//                         zoom: 15,
//                       ),
//                       onMapCreated: (controller) {
//                         _mapController = controller;
//                         _updateMarkers(vehicles.data);
//                       },
//                       myLocationEnabled: true,
//                       myLocationButtonEnabled: true,
//                       markers: _markers,
//                     ),
//               DraggableScrollableSheet(
//                 initialChildSize: 0.80,
//                 minChildSize: 0.35,
//                 maxChildSize: 0.8,
//                 builder: (context, scrollController) {
//                   return Container(
//                     padding: EdgeInsets.symmetric(horizontal: 16.w),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(16.r),
//                         topRight: Radius.circular(16.r),
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 10,
//                           spreadRadius: 5,
//                         ),
//                       ],
//                     ),
//                     child: ListView(
//                       padding: EdgeInsets.zero,
//                       controller: scrollController,
//                       children: [
//                         SizedBox(height: 8.h),
//                         Center(
//                           child: Container(
//                             width: 50.w,
//                             height: 4.h,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[300],
//                               borderRadius: BorderRadius.circular(10.r),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 8.h),
//                         Center(
//                           child: Text(
//                             "Choose a Trip",
//                             style: GoogleFonts.inter(
//                               fontSize: 18.sp,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 10.h),

//                         /// List of vehicles
//                         ListView.builder(
//                           padding: EdgeInsets.zero,
//                           physics: const NeverScrollableScrollPhysics(),
//                           shrinkWrap: true,
//                           itemCount: vehicles.data.length,
//                           itemBuilder: (context, index) {
//                             final vehicle = vehicles.data[index];
//                             return InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   selectIndex = index;
//                                 });
//                                 _updateMarkers(vehicles.data);
//                                 _mapController?.animateCamera(
//                                   CameraUpdate.newLatLng(
//                                     LatLng(vehicle.origLat, vehicle.origLon),
//                                   ),
//                                 );
//                               },
//                               child: Container(
//                                 margin: EdgeInsets.symmetric(vertical: 8.h),
//                                 padding: EdgeInsets.all(10.h),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(10.r),
//                                   border: Border.all(
//                                     color: selectIndex == index
//                                         ? Colors.black
//                                         : Colors.transparent,
//                                     width: 1,
//                                   ),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Image.network(
//                                       vehicle.image,
//                                       width: 50.w,
//                                       height: 50.h,
//                                       fit: BoxFit.cover,
//                                       errorBuilder: (context, error, st) {
//                                         return Image.asset(
//                                           "assets/car.png",
//                                           width: 50.w,
//                                           height: 50.h,
//                                         );
//                                       },
//                                     ),
//                                     SizedBox(width: 10.w),
//                                     Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           vehicle.vehicleType,
//                                           style: GoogleFonts.inter(
//                                             fontSize: 16.sp,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                         Text(
//                                           "₹${vehicle.price}",
//                                           style: GoogleFonts.inter(
//                                             fontSize: 14.sp,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                         SizedBox(height: 20.h),
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             minimumSize: Size(double.infinity, 50.h),
//                             backgroundColor: const Color(0xFF006970),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10.r),
//                             ),
//                           ),
//                           onPressed: isBooking
//                               ? null
//                               : () async {
//                                   setState(() => isBooking = true);
//                                   try {
//                                     final selectedVehicle =
//                                         vehicles.data[selectIndex];
//                                     final body = BookInstantDeliveryBodyModel(
//                                       vehicleTypeId:
//                                           selectedVehicle.vehicleTypeId,
//                                       price: double.parse(
//                                         selectedVehicle.price,
//                                       ).toInt(),
//                                       isCopanCode: false,
//                                       copanId: null.toString(),
//                                       copanAmount: 0,
//                                       coinAmount: 0,
//                                       taxAmount: 18,
//                                       userPayAmount: double.parse(
//                                         selectedVehicle.price,
//                                       ).toInt(),
//                                       distance: selectedVehicle.distance,
//                                       mobNo: "98767655678",
//                                       name: selectedVehicle.name,
//                                       origName: selectedVehicle.origName,
//                                       origLat: selectedVehicle.origLat,
//                                       origLon: selectedVehicle.origLon,
//                                       destName: selectedVehicle.destName,
//                                       destLat: selectedVehicle.destLat,
//                                       destLon: selectedVehicle.destLon,
//                                       picUpType: selectedVehicle.picUpType,
//                                     );

//                                     await ref
//                                         .read(bookDeliveryProvider.notifier)
//                                         .bookInstantDelivery(body);

//                                     Navigator.push(
//                                       context,
//                                       CupertinoPageRoute(
//                                         builder: (context) => PickupScreen(),
//                                       ),
//                                     );
//                                   } catch (e, st) {
//                                     log("${e.toString()} / ${st.toString()}");
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text("Booking failed: $e"),
//                                         behavior: SnackBarBehavior.floating,
//                                       ),
//                                     );
//                                   } finally {
//                                     setState(() {
//                                       isBooking = false;
//                                     });
//                                   }
//                                 },
//                           child: isBooking
//                               ? const CircularProgressIndicator(
//                                   color: Colors.white,
//                                 )
//                               : const Text("Book Now"),
//                         ),
//                         SizedBox(height: 20.h),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ],
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, st) => Center(child: Text(e.toString())),
//       ),
//     );
//   }
// }
