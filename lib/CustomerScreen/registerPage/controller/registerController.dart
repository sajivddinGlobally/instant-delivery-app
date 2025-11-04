import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/otpPage/otp.screen.dart';
import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/navigatorKey.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/registerBodyModel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

mixin Registercontroller<T extends StatefulWidget> on State<T> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
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
  Future<String> fcmGetToken() async {
    // Permission request करें (iOS/Android पर जरूरी)
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true, // iOS के लिए provisional permission
      carPlay: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
      return "no_permission"; // Return a fallback string instead of void
    }

    // FCM Token निकालें
    String? token = await FirebaseMessaging.instance.getToken();
    // setState(() {
    //   _fcmToken = token;
    // });
    print('FCM Token: $token'); // Console में print होगा - moved before return
    return token ?? "unknown_device";
  }
  void registerUser() async {
    final deviceId = await fcmGetToken();
    if (!registerformKey.currentState!.validate()) {
      setState(() => isLoading = false);
      return;
    }
    setState(() => isLoading = true);
    final body = RegisterBodyModel(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      email: emailController.text,
      phone: phoneNumberController.text,
      password: passwordController.text,
      deviceId: deviceId,
    );
    try {
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.userRegister(body);

      if (response.error == false) {
        Fluttertoast.showToast(msg: response.message);
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
            builder: (context) => OtpScreen(token: response.data!.token),
          ),
          (route) => false,
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
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      // );
    }
  }
}
