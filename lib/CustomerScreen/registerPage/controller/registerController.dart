import 'dart:developer';

import 'package:delivery_mvp_app/CustomerScreen/otpPage/otp.screen.dart';
import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/navigatorKey.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/registerBodyModel.dart';
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

  void registerUser() async {
    if (!formKey.currentState!.validate()) {
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
    );
    try {
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.userRegister(body);
      if (response.error == false) {
        Fluttertoast.showToast(msg: response.message);
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
            builder: (context) => OtpScreen(token: response.data.token),
          ),
          (route) => false,
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e, st) {
      setState(() {
        isLoading = false;
      });
      log(st.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }
}
