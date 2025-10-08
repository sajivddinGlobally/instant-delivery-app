import 'package:delivery_mvp_app/CustomerScreen/otpPage/controller/otpController.dart';
import 'package:delivery_mvp_app/config/utils/navigatorKey.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otp_pin_field/otp_pin_field.dart';

class OtpScreen extends StatefulWidget {
  final String token;
  const OtpScreen({super.key, required this.token});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with OtpController<OtpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 70.h),
            Center(
              child: Image.asset(
                "assets/scooter.png",
                width: 84.w,
                height: 72.h,
              ),
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
                    key: registerVerifyotpKey,
                    maxLength: 6,
                    fieldHeight: 50.h,
                    fieldWidth: 44.w,
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
                    onChange: (value) {
                      setState(() {
                        otp = value;
                      });
                    },
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
                    onPressed: () async {
                      sendOTP(widget.token);
                    },
                    child: loading
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            "Verify",
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                  ),
                  SizedBox(height: 25.h),
                  Center(
                    child: Text(
                      "By signing up, you agree to snap",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Terms of Service ",
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF111111),
                          decoration: TextDecoration.underline,
                        ),
                        children: [
                          TextSpan(
                            text: "and",
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF111111),
                              decoration: TextDecoration.none,
                            ),
                          ),
                          TextSpan(
                            text: " Privacy Policy.",
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF111111),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
