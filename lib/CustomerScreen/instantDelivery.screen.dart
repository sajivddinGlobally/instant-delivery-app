import 'package:delivery_mvp_app/CustomerScreen/selectTrip.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class InstantDeliveryScreen extends StatefulWidget {
  const InstantDeliveryScreen({super.key});

  @override
  State<InstantDeliveryScreen> createState() => _InstantDeliveryScreenState();
}

class _InstantDeliveryScreenState extends State<InstantDeliveryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 150.h,
                child: Text(
                  "dadfafasfadf",
                  style: GoogleFonts.inter(fontSize: 50.sp),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 50.h, left: 20.w),
                child: FloatingActionButton(
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
              ),
            ],
          ),
          Expanded(
            child: DraggableScrollableSheet(
              initialChildSize: 0.50, // bottom sheet height (35% of screen)
              // minChildSize: 0.15,
              // maxChildSize: 0.9,35
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
                    children: [
                      Center(
                        child: Container(
                          width: 50.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        "Instant Delivery",
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF111111),
                          letterSpacing: -1,
                        ),
                      ),
                      RideCard(),
                      SizedBox(height: 20.h),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
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
                                        ),
                                      ),
                                      Text(
                                        "Sri Saranakara Road",
                                        style: GoogleFonts.inter(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Color.fromARGB(127, 0, 0, 0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10.w, right: 10.w),
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
                                        ),
                                      ),
                                      Text(
                                        "Sri Saranakara Road",
                                        style: GoogleFonts.inter(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Color.fromARGB(127, 0, 0, 0),
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
                      SizedBox(height: 20.h),
                      Container(
                        margin: EdgeInsets.only(left: 20.w, right: 20.w),
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
                                builder: (context) => SelectTriPage(),
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
                      SizedBox(height: 30.h),
                    ],
                  ),
                );
              },
            ),
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
      margin: EdgeInsets.only(top: 20.h),
      width: 333.w,
      height: 177.h,
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
              Container(
                width: 170.w,
                height: 55.h,
                decoration: BoxDecoration(color: Color(0xFFEFEFEF)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF222222)),
                    SizedBox(width: 10.w),
                    Text(
                      "One Way",
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000000),
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 160.w,
                height: 55.h,
                decoration: BoxDecoration(color: Colors.transparent),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF222222)),
                    SizedBox(width: 10.w),
                    Text(
                      "Return Way",
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000000),
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 10.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text(
                      "Pickup",
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000000),
                        letterSpacing: -1,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    CircleAvatar(backgroundColor: Color(0xFF086E86), radius: 4),
                    SizedBox(height: 4.h),
                    CircleAvatar(backgroundColor: Color(0xFF086E86), radius: 4),
                    SizedBox(height: 4.h),
                    CircleAvatar(backgroundColor: Color(0xFF086E86), radius: 4),
                    SizedBox(height: 8.h),
                    Text(
                      "Drop",
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000000),
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF000000),
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          hintText: "ARH.VVK.Road",
                          hintStyle: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Divider(
                        color: Color.fromARGB(102, 120, 119, 141),
                        thickness: 2,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        "Masjid Al Ma...",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.favorite_border,
                        color: Color(0xFF000000),
                      ),
                    ),
                    SizedBox(height: 25.h),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.add,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Padding(
          //   padding: EdgeInsets.only(left: 20.w, right: 10.w),
          //   child: Row(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Column(
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: [
          //           Text(
          //             "Pickup",
          //             style: GoogleFonts.inter(
          //               fontSize: 18.sp,
          //               fontWeight: FontWeight.bold,
          //               color: Color(0xFF000000),
          //             ),
          //           ),
          //           SizedBox(height: 8.h),
          //           CircleAvatar(backgroundColor: Colors.amber, radius: 4),
          //           SizedBox(height: 4.h),
          //           CircleAvatar(backgroundColor: Colors.amber, radius: 4),
          //           SizedBox(height: 4.h),
          //           CircleAvatar(backgroundColor: Colors.amber, radius: 4),
          //         ],
          //       ),
          //       SizedBox(width: 10.w),
          //       Expanded(
          //         child: TextField(
          //           style: GoogleFonts.inter(
          //             fontSize: 16.sp,
          //             fontWeight: FontWeight.w500,
          //             color: Color(0xFF000000),
          //           ),
          //           decoration: InputDecoration(
          //             contentPadding: EdgeInsets.only(bottom: 10.h),
          //           ),
          //         ),
          //       ),
          //       IconButton(
          //         onPressed: () {},
          //         icon: Icon(
          //           Icons.favorite_border_outlined,
          //           color: Color(0xFF000000),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // Padding(
          //   padding: EdgeInsets.only(left: 20.w, right: 10.w),
          //   child: Row(
          //     crossAxisAlignment: CrossAxisAlignment.end,
          //     children: [
          //       Text(
          //         "Drop",
          //         style: GoogleFonts.inter(
          //           fontSize: 18.sp,
          //           fontWeight: FontWeight.bold,
          //           color: Color(0xFF000000),
          //         ),
          //       ),

          //       SizedBox(width: 10.w),
          //       Expanded(
          //         child: TextField(
          //           decoration: InputDecoration(
          //             contentPadding: EdgeInsets.only(bottom: 0),
          //           ),
          //         ),
          //       ),
          //       IconButton(
          //         onPressed: () {},
          //         icon: Icon(Icons.add, size: 25.sp, color: Color(0xFF000000)),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
