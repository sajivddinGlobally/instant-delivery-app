import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/home.screen.dart';
import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/navigatorKey.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/verifyRegisterBodyModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';

mixin OtpController<T extends StatefulWidget> on State<T> {
  String otp = "";
  bool loading = false;

  void sendOTP(String token) async {
    final body = VerifyRegisterBodyModel(token: token, otp: otp);
    setState(() {
      loading = true;
    });
    try {
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.verifyRegister(body);
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
        registerVerifyotpKey.currentState!.clearOtp();
      }
    } catch (e, st) {
      log("${e.toString()} / ${st.toString()}");
      setState(() {
        loading = false;
      });
      Fluttertoast.showToast(msg: "Error");
    }
  }
}
