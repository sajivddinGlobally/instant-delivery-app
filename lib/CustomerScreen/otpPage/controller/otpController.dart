import 'dart:developer';

import 'package:delivery_mvp_app/CustomerScreen/home.screen.dart';
import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/verifyRegisterBodyModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

mixin OtpController<T extends StatefulWidget> on State<T> {
  String otp = "";
  bool loading = false;

  void sendOTP(token) async {
    final body = VerifyRegisterBodyModel(token: token, otp: otp);
    setState(() {
      loading = true;
    });
    try {
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.verifyRegister(body);
      if (response.error == false) {
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => HomeScreen()),
          (route) => false,
        );
        Fluttertoast.showToast(msg: response.message);
        setState(() {
          loading = false;
        });
      }
    } catch (e, st) {
      log(st.toString());
      setState(() {
        loading = false;
      });
    }
  }
}
