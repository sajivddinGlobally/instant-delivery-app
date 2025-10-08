import 'package:delivery_mvp_app/CustomerScreen/forgotPage/controller/verifyOrResetController.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otp_pin_field/otp_pin_field.dart';

class VerifyOrResetpassPage extends StatefulWidget {
  final String token;
  final String email;
  const VerifyOrResetpassPage({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  State<VerifyOrResetpassPage> createState() => _VerifyOrResetpassPageState();
}

class _VerifyOrResetpassPageState extends State<VerifyOrResetpassPage>
    with VerifyOrResetController<VerifyOrResetpassPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SingleChildScrollView(
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
                "OTP Verification And Reset Password.",
                style: GoogleFonts.inter(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF111111),
                ),
              ),
              SizedBox(height: 7.h),
              Text(
                "Please input verification code  sent your email address and set password",
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF4F4F4F),
                ),
              ),
              SizedBox(height: 26.h),
              OtpPinField(
                key: forgotVerifyOTPKey,
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
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          forgotResendOTP(widget.email);
                        },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),
              if (otp.length == 6) ...[
                TextFormField(
                  controller: newPassController,
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
                    hintText: "New Password",
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password is required";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  controller: confirmPassController,
                  obscureText: show ? true : false,
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
                    hintText: "Confirm Password",
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF293540),
                    ),
                    suffixIcon: TextButton(
                      onPressed: () {
                        setState(() {
                          show = !show;
                        });
                      },
                      child: Text(
                        show ? "Show" : "Hide",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1D3557),
                        ),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password is required";
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
                      : () async {
                          verifyOrResetPassword(widget.token);
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
                          "Verify",
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
