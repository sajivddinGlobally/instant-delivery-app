import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class DeliveryHistoryScreen extends StatefulWidget {
  const DeliveryHistoryScreen({super.key});

  @override
  State<DeliveryHistoryScreen> createState() => _DeliveryHistoryScreenState();
}

class _DeliveryHistoryScreenState extends State<DeliveryHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          Row(
            children: [
              SizedBox(width: 25.w),
              Text(
                "Delivery History",
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF111111),
                  letterSpacing: -1.1,
                ),
              ),
              Spacer(),
              Container(
                width: 32.w,
                height: 35.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.r),
                  color: Color(0xFFF0F5F5),
                ),
                child: Center(
                  child: SvgPicture.asset("assets/SvgImage/icon.svg"),
                ),
              ),
              SizedBox(width: 24.w),
            ],
          ),
          SizedBox(height: 15.h),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: 4,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: 15.h,
                    left: 25.w,
                    right: 25.w,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ORDB1234",
                                style: GoogleFonts.inter(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0C341F),
                                ),
                              ),
                              Text(
                                "Receipient: Paul Pogba",
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF545454),
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          if (index == 0)
                            Container(
                              padding: EdgeInsets.only(
                                left: 6.w,
                                right: 6.w,
                                top: 2.h,
                                bottom: 2.h,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3.r),
                                color: Color(0xFFFFF4C7),
                              ),
                              child: Center(
                                child: Text(
                                  "In progress",
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF7E6604),
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: EdgeInsets.only(
                                left: 6.w,
                                right: 6.w,
                                top: 2.h,
                                bottom: 2.h,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3.r),
                                color: Color(0xFF27794D),
                              ),
                              child: Center(
                                child: Text(
                                  "Complete",
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                              ),
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
                          Column(
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
                                padding: EdgeInsets.only(left: 3.w, top: 2.h),
                                child: Text(
                                  "21b, Karimu Kotun Street, Victoria Island",
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF0C341F),
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                "12 January 2020, 2:43pm",
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF545454),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Divider(color: Color(0xFFDCE8E9)),
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
