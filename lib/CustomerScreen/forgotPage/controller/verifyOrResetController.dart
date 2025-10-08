import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/forgotPage/verifyOrResetPass.page.dart';
import 'package:delivery_mvp_app/CustomerScreen/loginPage/login.screen.dart';
import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/forgotSendOTPBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/verifyOrResetPassBodyModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:otp_pin_field/otp_pin_field.dart';

mixin VerifyOrResetController<T extends VerifyOrResetpassPage> on State<T> {
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();
  String otp = "";
  bool isShow = false;
  bool show = false;
  bool isLoading = false;

  final GlobalKey<OtpPinFieldState> forgotVerifyOTPKey =
      GlobalKey<OtpPinFieldState>();

  void verifyOrResetPassword(String token) async {
    final body = VerifyOrResetPassBodyModel(
      token: token,
      otp: otp,
      newPassword: newPassController.text,
      confirmPassword: confirmPassController.text,
    );
    setState(() {
      isLoading = true;
    });
    try {
      final service = APIStateNetwork(callPrettyDio());
      final respnose = await service.verifyOrResetPassword(body);
      if (respnose.error == false) {
        Fluttertoast.showToast(msg: respnose.message);
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
        setState(() {
          isLoading = false;
        });
      } else {
        Fluttertoast.showToast(msg: respnose.message);
        setState(() {
          isLoading = false;
        });
        forgotVerifyOTPKey.currentState!.clearOtp();
        log(respnose.message);
        newPassController.clear();
        confirmPassController.clear();
      }
    } catch (e, st) {
      setState(() {
        isLoading = false;
      });
      log("${e.toString()} / ${st.toString()}");
    }
  }

  void forgotResendOTP(email) async {
    final body = ForgotSentOtpBodyModel(loginType: email);
    try {
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.forgotSendOTP(body);
      if (response.error == false) {
        Fluttertoast.showToast(msg: response.message);
      } else {
        Fluttertoast.showToast(msg: response.message);
        forgotVerifyOTPKey.currentState!.clearOtp();
      }
    } catch (e, st) {
      log("${e.toString()} / ${st.toString()}");
    }
  }
}
