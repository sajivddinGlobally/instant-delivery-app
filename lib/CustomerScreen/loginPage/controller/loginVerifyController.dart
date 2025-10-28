import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/home.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/loginPage/loginVerify.screen.dart';
import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/navigatorKey.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/loginBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/loginVerifyBodyModel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';

mixin LoginVerifyController<T extends LoginVerifyScreen> on State<T> {
  String otp = "";
  bool loading = false;
  Future<String> _getDeviceToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      return token ?? "unknown_device";
    } catch (e) {
      log("Error getting device token: $e");
      return "unknown_device";
    }
  }

  void verifyLogin(String token) async {
    final body = LoginverifyBodyModel(token: token, otp: otp);
    setState(() {
      loading = true;
    });
    try {
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.verifyLogin(body);

      if (response.error == false) {
        var box = Hive.box("folder");
        await box.put("token", response.data!.token);
        await box.put("email", response.data!.email);
        await box.put("firstName", response.data!.firstName);
        await box.put("lastName", response.data!.lastName);
        await box.put("phone", response.data!.phone);
        await box.put("id", response.data!.id);

        Fluttertoast.showToast(msg: response.message);
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
        setState(() {
          loading = false;
        });
      } else {
        Fluttertoast.showToast(msg: response.message);
        setState(() {
          loading = false;
          otp = "";
        });
        loginVerifyotpKey.currentState!.clearOtp();
      }
    } catch (e, st) {
      log("${e.toString()} / ${st.toString()}");
      setState(() {
        loading = false;
      });
      Fluttertoast.showToast(msg: "Error");
    }
  }

  void resendOTP(email, pass) async {
    final deviceId = await _getDeviceToken();
    final body = LoginBodyModel(
      loginType: email,
      password: pass,
      deviceId: deviceId,
    );
    try {
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.login(body);
      if (response.error == false) {
        Fluttertoast.showToast(msg: response.message);
      } else {
        Fluttertoast.showToast(msg: response.message);
      }
    } catch (e, st) {
      log("${e.toString()} / ${st.toString()}");
    }
  }
}
