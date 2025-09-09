import 'package:delivery_mvp_app/CustomerScreen/login.screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class OnbordingScreen extends StatefulWidget {
  const OnbordingScreen({super.key});

  @override
  State<OnbordingScreen> createState() => _OnbordingScreenState();
}

class _OnbordingScreenState extends State<OnbordingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Padding(
        padding: EdgeInsets.only(left: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SvgPicture.asset("assets/SvgImage/service.svg"),
            Image.asset("assets/man.png"),
            SizedBox(height: 30.h),
            Padding(
              padding: EdgeInsets.only(right: 60.w),
              child: Text(
                "Request for Delivery in few clicks",
                style: GoogleFonts.abhayaLibre(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF086E86),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.only(right: 60.w),
              child: Text(
                "On-demand delivery whenever and wherever the need arises.",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF086E86),
                  //letterSpacing: -0.55,
                ),
              ),
            ),
            SizedBox(height: 30.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(317.w, 50.h),
                backgroundColor: Color(0xFF006970),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text(
                "Get Started",
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
