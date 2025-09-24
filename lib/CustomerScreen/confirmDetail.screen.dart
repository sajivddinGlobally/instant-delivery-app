import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ConfirmDetailScreen extends StatefulWidget {
  const ConfirmDetailScreen({super.key});

  @override
  State<ConfirmDetailScreen> createState() => _ConfirmDetailScreenState();
}

class _ConfirmDetailScreenState extends State<ConfirmDetailScreen> {
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
                            "Confirm Details",
                            style: GoogleFonts.inter(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF111111),
                              letterSpacing: -1.1,
                            ),
                          ),
                          SizedBox(height: 15.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: Color(0xFFDE4B65),
                                  ),
                                  SizedBox(height: 7.h),
                                  CircleAvatar(
                                    backgroundColor: Color(0xFF28B877),
                                    radius: 2.r,
                                  ),
                                  SizedBox(height: 6.h),
                                  CircleAvatar(
                                    backgroundColor: Color(0xFF28B877),
                                    radius: 2.r,
                                  ),
                                  SizedBox(height: 6.h),
                                  CircleAvatar(
                                    backgroundColor: Color(0xFF28B877),
                                    radius: 2.r,
                                  ),
                                  SizedBox(height: 7.h),
                                  Icon(
                                    Icons.circle_outlined,
                                    color: Color(0xFF28B877),
                                    size: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    weight: 20,
                                  ),
                                ],
                              ),

                              SizedBox(width: 20.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 2.h),
                                  Container(
                                    width: 285.w,
                                    // color: Colors.amber,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Pickup Location",
                                              style: GoogleFonts.inter(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w400,
                                                color: Color(0xFF77869E),
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              "32 Samwell Sq, Chevron",
                                              style: GoogleFonts.inter(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF111111),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                        Container(
                                          width: 35.w,
                                          height: 28.h,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              5.r,
                                            ),
                                            color: Color(0xFFF7F7F7),
                                          ),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              "assets/SvgImage/bikess.svg",
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 18.h),
                                  Text(
                                    "Delivery Location",
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF77869E),
                                    ),
                                  ),
                                  Text(
                                    "21b, Karimu Kotun Street, Victoria Island",
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF111111),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              buildAddress(),
                              SizedBox(width: 25.w),
                              buildAddress(),
                            ],
                          ),
                               SizedBox(height: 16.h),
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
                                // Navigator.push(
                                //   context,
                                //   CupertinoPageRoute(
                                //     builder: (context) => SelectTripScreen(),
                                //   ),
                                // );
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

  Widget buildAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "What you are sending",
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: Color(0xFF77869E),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          "Electronics/Gadgets",
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111111),
          ),
        ),
      ],
    );
  }
}
