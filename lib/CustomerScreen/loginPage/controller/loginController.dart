import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/loginPage/login.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/loginPage/loginVerify.screen.dart';
import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/loginBodyModel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

mixin LoginController<T extends LoginScreen> on State<T> {
  final loginformKey = GlobalKey<FormState>();
  bool isShow = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loadind = false;

 Future<String> getDeviceToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      return token ?? "unknown_device";
    } catch (e) {
      log("Error getting device token: $e");
      return "unknown_device";
    }
  }
  

  void loginUser() async {
    final diviceID = await getDeviceToken();
    if (!loginformKey.currentState!.validate()) {
      setState(() {
        loadind = false;
      });
      return;
    }

    setState(() {
      loadind = true;
    });
    final body = LoginBodyModel(
      loginType: emailController.text,
      password: passwordController.text,
      deviceId:diviceID,
    );
    try {
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.login(body);

      if (response.error == false) {
        Fluttertoast.showToast(msg: response.message);
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
            builder: (context) => LoginVerifyScreen(
              token: response.data!.token,
              email: emailController.text,
              pass: passwordController.text,
            ),
          ),
          (route) => false,
        );
        setState(() {
          loadind = false;
        });
      } else {
        Fluttertoast.showToast(msg: response.message);
        setState(() {
          loadind = false;
        });
      }
    } catch (e, st) {
      setState(() {
        loadind = false;
      });
      log("${e.toString()} / ${st.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error:${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(left: 15.w, bottom: 15.h, right: 15.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
            side: BorderSide.none,
          ),
        ),
      );
    }
  }
}
