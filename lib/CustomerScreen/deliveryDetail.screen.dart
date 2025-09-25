import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class DeliveryDetailScreen extends StatefulWidget {
  const DeliveryDetailScreen({super.key});

  @override
  State<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends State<DeliveryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        automaticallyImplyLeading: false,
        leading: Container(
          margin: EdgeInsets.only(left: 15.w),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, color: Color(0xFF006970)),
          ),
        ),
        title: Text(
          "Delivery details",
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w400,
            color: Color(0xFF111111),
            letterSpacing: -1.1,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 25.w, right: 25.w, top: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  child: ClipOval(
                    child: Image.asset("assets/alli.png", fit: BoxFit.cover),
                  ),
                ),
                SizedBox(width: 13.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Allan Smith",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF111111),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "124 Deliveries",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4F4F4F),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.yellow, size: 18.sp),
                        Icon(Icons.star, color: Colors.yellow, size: 18.sp),
                        Icon(Icons.star, color: Colors.yellow, size: 18.sp),
                        Icon(Icons.star, color: Colors.yellow, size: 18.sp),
                        Icon(Icons.star, color: Colors.yellow, size: 18.sp),
                        SizedBox(width: 4.w),
                        Text(
                          "4.1",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4F4F4F),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Spacer(),
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
                SizedBox(width: 10.w),
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.r),
                    color: Color(0xFFF7F7F7),
                  ),
                  child: Center(
                    child: SvgPicture.asset("assets/SvgImage/bikess.svg"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Color(0xFFDE4B65),
                      size: 22.sp,
                    ),
                    SizedBox(height: 6.h),
                    CircleAvatar(
                      backgroundColor: Color(0xFF28B877),
                      radius: 2.r,
                    ),
                    SizedBox(height: 5.h),
                    CircleAvatar(
                      backgroundColor: Color(0xFF28B877),
                      radius: 2.r,
                    ),
                    SizedBox(height: 5.h),
                    CircleAvatar(
                      backgroundColor: Color(0xFF28B877),
                      radius: 2.r,
                    ),
                    SizedBox(height: 6.h),
                    Icon(
                      Icons.circle_outlined,
                      color: Color(0xFF28B877),
                      size: 17.sp,
                      fontWeight: FontWeight.bold,
                      weight: 20,
                    ),
                  ],
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pickup Location",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF77869E),
                          ),
                        ),
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
            SizedBox(height: 15.h),
            Row(
              children: [
                buildAddress("What you are sending", "Electronics/Gadgets"),
                SizedBox(width: 25.w),
                buildAddress("Receipient", "Donald Duck"),
              ],
            ),
            SizedBox(height: 15.h),
            buildAddress("Receipient contact number", "08123456789"),
            SizedBox(height: 15.h),
            Row(
              children: [
                buildAddress("Payment", "Card"),
                SizedBox(width: 25.w),
                buildAddress("Fee", "\$150"),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              "Pickup image(s)",
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: Color(0xFF77869E),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64.w,
                  height: 64.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5.w),
                  width: 64.w,
                  height: 64.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAddress(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: Color(0xFF77869E),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          subtitle,
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
