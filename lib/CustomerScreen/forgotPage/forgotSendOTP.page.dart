import 'package:delivery_mvp_app/CustomerScreen/forgotPage/controller/forgotSendOTPController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotSendOTPPage extends StatefulWidget {
  const ForgotSendOTPPage({super.key});

  @override
  State<ForgotSendOTPPage> createState() => _ForgotSendOTPPageState();
}

class _ForgotSendOTPPageState extends State<ForgotSendOTPPage>
    with ForgotSendOTPController<ForgotSendOTPPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Form(
        key: forgotSentOTPformKey,
        child: Padding(
          padding: EdgeInsets.only(left: 24.w, right: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 66.h),
              Center(
                child: Image.asset(
                  "assets/scooter.png",
                  width: 84.w,
                  height: 72.h,
                ),
              ),
              SizedBox(height: 30.h),
              Text(
                "Forgot Password?",
                style: GoogleFonts.inter(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF111111),
                ),
              ),
              SizedBox(height: 7.h),
              Text(
                "Don't worry! It occurs. Please enter the email address linked with your account.",
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF4F4F4F),
                ),
              ),
              SizedBox(height: 30.h),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF293540),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFF0F5F5),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                    borderSide: BorderSide(
                      color: Color(0xFF006970),
                      width: 1.w,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.r),
                    borderSide: BorderSide(color: Colors.red, width: 1.w),
                  ),
                  hintText: "Your Email",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF787B7B),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email is required";
                  }
                  String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                  RegExp regex = RegExp(pattern);
                  if (!regex.hasMatch(value.trim())) {
                    return "Enter a valid email";
                  }
                  return null;
                },
              ),
              SizedBox(height: 30.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(327.w, 50.h),
                  backgroundColor: Color(0xFF006970),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    side: BorderSide.none,
                  ),
                ),
                onPressed: isLoading
                    ? null
                    : () {
                        forgotSendOTP();
                      },
                child: isLoading
                    ? Center(
                        child: SizedBox(
                          width: 30.w,
                          height: 30.h,
                          child: CircularProgressIndicator(strokeWidth: 2.w),
                        ),
                      )
                    : Text(
                        "Send OTP",
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
