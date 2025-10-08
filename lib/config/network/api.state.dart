import 'package:delivery_mvp_app/data/Model/forgotSendOTPBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/forgotSentOTPRestModel.dart';
import 'package:delivery_mvp_app/data/Model/loginBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/loginResModel.dart';
import 'package:delivery_mvp_app/data/Model/loginVerifyBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/loginVerifyResModel.dart';
import 'package:delivery_mvp_app/data/Model/registerBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/registerResModel.dart';
import 'package:delivery_mvp_app/data/Model/verifyOrResetPassBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/verifyOrResetPassResModel.dart';
import 'package:delivery_mvp_app/data/Model/verifyRegisterBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/verifyRegisterResModel.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api.state.g.dart';

@RestApi(baseUrl: "https://weloads.com/api")
abstract class APIStateNetwork {
  factory APIStateNetwork(Dio dio, {String baseUrl}) = _APIStateNetwork;

  @POST("/v1/user/register")
  Future<RegisterResModel> userRegister(@Body() RegisterBodyModel body);

  @POST("/v1/user/registerVerify")
  Future<VerifyRegisterResModel> verifyRegister(
    @Body() VerifyRegisterBodyModel body,
  );

  @POST("/v1/user/login")
  Future<LoginResModel> login(@Body() LoginBodyModel body);

  @POST("/v1/user/verifyUser")
  Future<LoginverifyResModel> verifyLogin(@Body() LoginverifyBodyModel body);

  @POST("/v1/user/forgotPassword")
  Future<ForgotSentOtpResModel> forgotSendOTP(
    @Body() ForgotSentOtpBodyModel body,
  );

  @POST("/v1/user/forgotPasswordVerify")
  Future<VerifyOrResetPassResModel> verifyOrResetPassword(
    @Body() VerifyOrResetPassBodyModel body,
  );
}
