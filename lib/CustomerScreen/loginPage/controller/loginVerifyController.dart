import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/home.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/loginPage/loginVerify.screen.dart';
import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/navigatorKey.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/loginVerifyBodyModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';

mixin LoginVerifyController<T extends LoginVerifyScreen> on State<T> {
  String otp = "";
  bool loading = false;

  void verifyLogin(String token) async {
    final body = LoginverifyBodyModel(token: token, otp: otp);
    setState(() {
      loading = true;
    });
    try {
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.verifyLogin(body);
      var box = Hive.box("folder");
      await box.put("token", response.data);
      if (response.error == false) {
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
}
