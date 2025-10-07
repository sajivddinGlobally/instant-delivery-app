import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/loginPage/login.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/loginPage/loginVerify.screen.dart';
import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/navigatorKey.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/loginBodyModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/adapters.dart';

mixin LoginController<T extends LoginScreen> on State<T> {
  bool isShow = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loadind = false;

  void loginUser() async {
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
    );
    try {
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.login(body);
      var box = Hive.box("folder");
      await box.put("token", response.data.token);
      if (response.error == false) {
        Fluttertoast.showToast(msg: response.message);
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
            builder: (context) => LoginVerifyScreen(token: response.data.token),
          ),
          (route) => false,
        );
        setState(() {
          loadind = false;
        });
      } else {
        log("Something went wrong");
        setState(() {
          loadind = false;
        });
      }
    } catch (e, st) {
      setState(() {
        loadind = false;
      });
      log("${e.toString()} / ${st.toString()}");
    }
  }
}
