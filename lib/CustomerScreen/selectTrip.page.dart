import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectTriPage extends StatefulWidget {
  const SelectTriPage({super.key});

  @override
  State<SelectTriPage> createState() => _SelectTriPageState();
}

class _SelectTriPageState extends State<SelectTriPage> {
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
              // initialChildSize: 0.80, // bottom sheet height (35% of screen)
              // minChildSize: 0.15,
              // maxChildSize: 0.9,
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
                      SizedBox(height: 10.h),
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
                      SizedBox(height: 18.h),
                      Container(
                        width: double.infinity,
                        height: 160.h,
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
                              child: Image.asset(
                                "assets/car.png",
                                width: 106.w,
                                height: 60.h,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 18.w),
                                  child: Text(
                                    "Delivery Go",
                                    style: GoogleFonts.inter(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xfF000000),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 18.w),
                                  child: Text(
                                    "₹170.71",
                                    style: GoogleFonts.inter(
                                      fontSize: 20.sp,
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
                                      fontSize: 16.sp,
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
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF000000),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Container(
                              margin: EdgeInsets.only(left: 18.w),
                              width: 82.w,
                              height: 22.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.r),
                                color: Color(0xFF3B6CE9),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bolt,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                  Text(
                                    "Faster",
                                    style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: 2,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(top: 10.h),
                            child: Row(
                              children: [
                                Image.asset(
                                  "assets/b.png",
                                  width: 50.w,
                                  height: 50.h,
                                ),
                                SizedBox(width: 20.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Trip ${index + 1}",
                                      style: GoogleFonts.inter(fontSize: 16.sp),
                                    ),
                                    Text(
                                      "Details here",
                                      style: GoogleFonts.inter(fontSize: 14.sp),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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
