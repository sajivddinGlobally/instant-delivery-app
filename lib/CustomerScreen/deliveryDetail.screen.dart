import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      body: Column(
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
                width: 35.w,
                height: 32.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.r),
                  color: Color(0xFFF0F5F5),
                ),
                child: Center(
                  child: Icon(Icons.call, color: Color(0xFF17A008)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
