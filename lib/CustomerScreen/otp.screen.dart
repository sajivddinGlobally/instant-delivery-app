import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otp_pin_field/otp_pin_field.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50.h),
          Center(
            child: Image.asset("assets/scooter.png", width: 84.w, height: 72.h),
          ),
          Padding(
            padding: EdgeInsets.only(left: 24.w, right: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 28.h),
                Text(
                  "Enter the 4-digit code",
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF111111),
                    letterSpacing: -1,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Please input  the verification code sent to your phone number 23480*******90",
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF4F4F4F),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: Size(0, 30.h),
                    padding: EdgeInsets.only(left: 0, top: 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {},
                  child: Text(
                    "Change Number?",
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF006970),
                    ),
                  ),
                ),
                SizedBox(height: 26.h),
                OtpPinField(
                  maxLength: 4,
                  fieldHeight: 46.h,
                  fieldWidth: 50.w,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  keyboardType: TextInputType.number,
                  otpPinFieldStyle: OtpPinFieldStyle(
                    textStyle: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D2D2D),
                    ),
                    activeFieldBackgroundColor: Color(0xFFF0F5F5),
                    defaultFieldBackgroundColor: Color(0xFFF0F5F5),
                    activeFieldBorderColor: Colors.transparent,
                    defaultFieldBorderColor: Colors.transparent,
                  ),
                  otpPinFieldDecoration:
                      OtpPinFieldDecoration.defaultPinBoxDecoration,

                  onSubmit: (text) {},
                  onChange: (text) {},
                ),
                SizedBox(height: 20.h),
                Text.rich(
                  TextSpan(
                    text: "Didn’t get any code yet? ",
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4F4F4F),
                    ),
                    children: [
                      TextSpan(
                        text: "Resend code",
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF006970),
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {},
                      ),
                    ],
                  ),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (context) => OtpScreen()),
                    );
                  },
                  child: Text(
                    "Login",
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
                SizedBox(height: 7.h),
                // Center(
                //   child: Text.rich(
                //     TextSpan(
                //       text: "Need an account? ",
                //       style: GoogleFonts.inter(
                //         fontSize: 14.sp,
                //         fontWeight: FontWeight.w400,
                //         color: Color(0xFF4F4F4F),
                //       ),
                //       children: [
                //         TextSpan(
                //           text: "Sign up",
                //           style: GoogleFonts.inter(
                //             fontSize: 16.sp,
                //             fontWeight: FontWeight.w500,
                //             color: Color(0xFF006970),
                //           ),
                //           recognizer: TapGestureRecognizer()
                //             ..onTap = () {
                //               Navigator.push(
                //                 context,
                //                 CupertinoPageRoute(
                //                   builder: (_) => RegisterScreen(),
                //                 ),
                //               );
                //             },
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                SizedBox(height: 10.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
