import 'package:delivery_mvp_app/CustomerScreen/selectTrip.screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class InstantDeliveryScreen extends StatefulWidget {
  const InstantDeliveryScreen({super.key});

  @override
  State<InstantDeliveryScreen> createState() => _InstantDeliveryScreenState();
}

class _InstantDeliveryScreenState extends State<InstantDeliveryScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLatLng;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
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
      _currentLatLng = LatLng(position.latitude, position.longitude);
    });

    _mapController?.animateCamera(CameraUpdate.newLatLng(_currentLatLng!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFFFFFFF),
        shape: CircleBorder(),
        onPressed: () {
          Navigator.pop(context);
        },
        child: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: Icon(Icons.arrow_back_ios, color: Color(0xFF1D3557)),
        ),
      ),
      body: _currentLatLng == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLatLng!,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),

                DraggableScrollableSheet(
                  initialChildSize: 0.53, // 🔹 Sheet shuru me 45% height lega
                  minChildSize: 0.25, // 🔹 Sabse chhoti height
                  maxChildSize: 0.53, // 🔹 Upar drag karke max kitna khule
                  builder: (context, scrollController) {
                    return Container(
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
                        controller: scrollController,
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
                          SizedBox(height: 5.h),
                          Text(
                            "Instant Delivery",
                            style: GoogleFonts.inter(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF111111),
                              letterSpacing: -1,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 10.w,
                              right: 10.w,
                              top: 12.h,
                            ),
                            child: RideCard(),
                          ),
                          SizedBox(height: 15.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                  left: 10.w,
                                  right: 10.w,
                                  top: 5.h,
                                  bottom: 5.h,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.r),
                                  color: Color(0xFFFFFFFF),
                                  boxShadow: [
                                    BoxShadow(
                                      offset: Offset(0, 0),
                                      spreadRadius: 0,
                                      blurRadius: 1,
                                      color: Color.fromARGB(63, 0, 0, 0),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 30.w,
                                      height: 30.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF086E86),
                                      ),
                                      child: Icon(
                                        Icons.location_on,
                                        color: Color(0xFFDE4B65),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "ARH Hardware",
                                          style: GoogleFonts.inter(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF000000),
                                            letterSpacing: -1,
                                          ),
                                        ),
                                        Text(
                                          "Sri Saranakara Road",
                                          style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Color.fromARGB(127, 0, 0, 0),
                                            letterSpacing: -1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Container(
                                padding: EdgeInsets.only(
                                  left: 10.w,
                                  right: 10.w,
                                  top: 5.h,
                                  bottom: 5.h,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.r),
                                  color: Color(0xFFFFFFFF),
                                  boxShadow: [
                                    BoxShadow(
                                      offset: Offset(0, 0),
                                      spreadRadius: 0,
                                      blurRadius: 1,
                                      color: Color.fromARGB(63, 0, 0, 0),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 30.w,
                                      height: 30.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF086E86),
                                      ),
                                      child: Icon(
                                        Icons.location_on,
                                        color: Color(0xFFDE4B65),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "ARH Hardware",
                                          style: GoogleFonts.inter(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xFF000000),
                                            letterSpacing: -1,
                                          ),
                                        ),
                                        Text(
                                          "Sri Saranakara Road",
                                          style: GoogleFonts.inter(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Color.fromARGB(127, 0, 0, 0),
                                            letterSpacing: -1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15.h),
                          Container(
                            margin: EdgeInsets.only(left: 15.w, right: 15.w),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 50.h),
                                backgroundColor: Color(0xFF006970),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => SelectTripScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Next",
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class RideCard extends StatefulWidget {
  const RideCard({super.key});

  @override
  State<RideCard> createState() => _RideCardState();
}

class _RideCardState extends State<RideCard> {
  bool oneWay = true;
  bool returnWay = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 135.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13.r),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40.h,
                  color: Color(0xFFEFEFEF),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFF222222),
                        size: 20.sp,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        "One Way",
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 40.h,
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFF222222),
                        size: 20.sp,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        "Return Way",
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          //SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Pickup",
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: -1,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    CircleAvatar(
                      backgroundColor: Color(0xFF086E86),
                      radius: 3.r,
                    ),
                    SizedBox(height: 4.h),
                    CircleAvatar(
                      backgroundColor: Color(0xFF086E86),
                      radius: 3.r,
                    ),
                    SizedBox(height: 4.h),
                    CircleAvatar(
                      backgroundColor: Color(0xFF086E86),
                      radius: 3.r,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      "Drop",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText: "ARH.VVK.Road",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Divider(
                        color: Color.fromARGB(102, 120, 119, 141),
                        thickness: 2,
                        height: 2,
                      ),
                      SizedBox(height: 4.h),
                      TextField(
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText: "Masjid Al Ma...",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.favorite_border, color: Colors.black),
                    ),
                    SizedBox(height: 6.h),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.add, color: Colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // return Container(
    //   width: MediaQuery.of(context).size.width,
    //   height: 155.h,
    //   decoration: BoxDecoration(
    //     color: Colors.white,
    //     borderRadius: BorderRadius.circular(13.r),
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
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Row(
    //         mainAxisAlignment: MainAxisAlignment.start,
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Container(
    //             width: 160.w,
    //             height: 40.h,
    //             decoration: BoxDecoration(color: Color(0xFFEFEFEF)),
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 Icon(
    //                   Icons.check_circle,
    //                   color: Color(0xFF222222),
    //                   size: 20.sp,
    //                 ),
    //                 SizedBox(width: 10.w),
    //                 Text(
    //                   "One Way",
    //                   style: GoogleFonts.inter(
    //                     fontSize: 15.sp,
    //                     fontWeight: FontWeight.w600,
    //                     color: Color(0xFF000000),
    //                     letterSpacing: -1,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //           Container(
    //             width: 160.w,
    //             height: 40.h,
    //             decoration: BoxDecoration(color: Colors.transparent),
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 Icon(
    //                   Icons.check_circle,
    //                   color: Color(0xFF222222),
    //                   size: 20.sp,
    //                 ),
    //                 SizedBox(width: 10.w),
    //                 Text(
    //                   "Return Way",
    //                   style: GoogleFonts.inter(
    //                     fontSize: 15.sp,
    //                     fontWeight: FontWeight.w600,
    //                     color: Color(0xFF000000),
    //                     letterSpacing: -1,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ],
    //       ),
    //       SizedBox(height: 10.h),
    //       Padding(
    //         padding: EdgeInsets.only(left: 16.w, right: 10.w),
    //         child: Row(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Column(
    //               children: [
    //                 Text(
    //                   "Pickup",
    //                   style: GoogleFonts.inter(
    //                     fontSize: 15.sp,
    //                     fontWeight: FontWeight.bold,
    //                     color: Color(0xFF000000),
    //                     letterSpacing: -1,
    //                   ),
    //                 ),
    //                 SizedBox(height: 8.h),
    //                 CircleAvatar(backgroundColor: Color(0xFF086E86), radius: 4),
    //                 SizedBox(height: 4.h),
    //                 CircleAvatar(backgroundColor: Color(0xFF086E86), radius: 4),
    //                 SizedBox(height: 4.h),
    //                 CircleAvatar(backgroundColor: Color(0xFF086E86), radius: 4),
    //                 SizedBox(height: 8.h),
    //                 Text(
    //                   "Drop",
    //                   style: GoogleFonts.inter(
    //                     fontSize: 14.sp,
    //                     fontWeight: FontWeight.bold,
    //                     color: Color(0xFF000000),
    //                     letterSpacing: -1,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //             SizedBox(width: 6.w),
    //             Expanded(
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 mainAxisAlignment: MainAxisAlignment.end,
    //                 children: [
    //                   TextField(
    //                     style: GoogleFonts.inter(
    //                       fontSize: 15.sp,
    //                       fontWeight: FontWeight.w500,
    //                       color: Color(0xFF000000),
    //                     ),
    //                     decoration: InputDecoration(
    //                       contentPadding: EdgeInsets.zero,
    //                       border: OutlineInputBorder(
    //                         borderSide: BorderSide.none,
    //                       ),
    //                       hintText: "ARH.VVK.Road",
    //                       hintStyle: GoogleFonts.inter(
    //                         fontSize: 14.sp,
    //                         fontWeight: FontWeight.w500,
    //                         color: Color(0xFF000000),
    //                       ),
    //                     ),
    //                   ),
    //                   Divider(
    //                     color: Color.fromARGB(102, 120, 119, 141),
    //                     thickness: 2,
    //                   ),
    //                   TextField(
    //                     style: GoogleFonts.inter(
    //                       fontSize: 15.sp,
    //                       fontWeight: FontWeight.w500,
    //                       color: Color(0xFF000000),
    //                     ),
    //                     decoration: InputDecoration(
    //                       contentPadding: EdgeInsets.zero,
    //                       border: OutlineInputBorder(
    //                         borderSide: BorderSide.none,
    //                       ),
    //                       hintText: "Masjid Al Ma...",
    //                       hintStyle: GoogleFonts.inter(
    //                         fontSize: 14.sp,
    //                         fontWeight: FontWeight.w500,
    //                         color: Color(0xFF000000),
    //                       ),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             Column(
    //               crossAxisAlignment: CrossAxisAlignment.end,
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 IconButton(
    //                   onPressed: () {},
    //                   icon: Icon(
    //                     Icons.favorite_border,
    //                     color: Color(0xFF000000),
    //                   ),
    //                 ),
    //                 SizedBox(height: 10.h),
    //                 IconButton(
    //                   onPressed: () {},
    //                   icon: Icon(
    //                     Icons.add,
    //                     fontWeight: FontWeight.bold,
    //                     color: Color(0xFF000000),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
