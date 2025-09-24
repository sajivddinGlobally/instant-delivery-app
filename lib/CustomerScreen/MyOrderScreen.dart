import 'package:another_stepper/widgets/another_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40.h),
          Center(
            child: Text(
              "Checkout",
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
              ),
            ),
          ),
          SizedBox(height: 30.h),
          Container(
            margin: EdgeInsets.only(left: 20.w),
            child: Text(
              "Your Order",
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnotherStepper(
                  stepperList: [],
                  stepperDirection: Axis.vertical,
                  activeBarColor: const Color(0xFF2490A9),
                  inActiveBarColor: const Color(0xFFEDEDED),
                  verticalGap: 30, // gap between steps
                  barThickness: 2,
                  activeIndex: 1, // highlight till 2nd step
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
