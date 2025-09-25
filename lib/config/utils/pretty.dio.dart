import 'package:dio/dio.dart';
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
  return dio;
}
