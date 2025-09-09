import 'package:delivery_mvp_app/CustomerScreen/otp.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/register.screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isShow = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50.h),
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
                    "Welcome",
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF111111),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Please input your details",
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF4F4F4F),
                    ),
                  ),
                  SizedBox(height: 35.h),
                  TextFormField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFF0F5F5),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: BorderSide.none,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "youremailaddress@address.com",
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF293540),
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h),
                  TextFormField(
                    obscureText: isShow ? true : false,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFF0F5F5),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: BorderSide.none,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Password",
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF293540),
                      ),
                      suffixIcon: TextButton(
                        onPressed: () {
                          setState(() {
                            isShow = !isShow;
                          });
                        },
                        child: Text(
                          isShow ? "Show" : "Hide",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF1D3557),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111111),
                        ),
                      ),
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
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Need an account? ",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF4F4F4F),
                        ),
                        children: [
                          TextSpan(
                            text: "Sign up",
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF006970),
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => RegisterScreen(),
                                  ),
                                );
                              },
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
