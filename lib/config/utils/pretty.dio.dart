import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/loginPage/login.screen.dart';
import 'package:delivery_mvp_app/config/utils/navigatorKey.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

Dio callPrettyDio() {
  final dio = Dio();
  dio.interceptors.add(
    PrettyDioLogger(
      requestBody: true,
      requestHeader: true,
      responseBody: true,
      responseHeader: true,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers.addAll({'Content-Type': 'application/json'});
      },
      onError: (DioException error, handler) {
        final globalContext = navigatorKey.currentContext;
        String message = "Something went wrong";
        if (error.response != null) {
          final data = error.response!.data;
          if (data is Map<String, dynamic>) {
            message = data['message'] ?? data.toString();
          } else {
            message = data.toString();
          }
        } else {
          message = error.message ?? error.toString();
        }

        log("Dio Error: $message", stackTrace: error.stackTrace);

        if (globalContext != null) {
          if (error.response?.statusCode == 401) {
            ScaffoldMessenger.of(globalContext).showSnackBar(
              const SnackBar(
                content: Text("Token expired. Please login again."),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.pushAndRemoveUntil(
              globalContext,
              CupertinoPageRoute(builder: (_) => LoginScreen()),
              (route) => false,
            );
          } else {
            ScaffoldMessenger.of(globalContext).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.red),
            );
          }
        }
        handler.next(error);
      },
      onResponse: (response, handler) {},
    ),
  );

  return dio;
}
