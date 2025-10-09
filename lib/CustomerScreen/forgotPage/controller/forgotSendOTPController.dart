import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/forgotPage/forgotSendOTP.page.dart';
import 'package:delivery_mvp_app/CustomerScreen/forgotPage/verifyOrResetPass.page.dart';
import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/forgotSendOTPBodyModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

mixin ForgotSendOTPController<T extends ForgotSendOTPPage> on State<T> {
  final forgotSentOTPformKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool isLoading = false;

  void forgotSendOTP() async {
    if (!forgotSentOTPformKey.currentState!.validate()) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    setState(() {
      isLoading = true;
    });
    final body = ForgotSentOtpBodyModel(loginType: emailController.text);
    try {
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.forgotSendOTP(body);
      if (response.error == false) {
        Fluttertoast.showToast(msg: response.message);
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => VerifyOrResetpassPage(
              token: response.data!.token,
              email: emailController.text,
            ),
          ),
        );
        setState(() {
          isLoading = false;
        });
      } else {
        Fluttertoast.showToast(msg: response.message);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e, st) {
      setState(() {
        isLoading = false;
      });
      log("${e.toString()} / ${st.toString()}");
    }
  }
}
