import 'dart:io';

import 'package:delivery_mvp_app/data/Model/UpdateAddressBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/bookInstantDeliveryResModel.dart';
import 'package:delivery_mvp_app/data/Model/bookInstantdeliveryBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/deliveryCancelByUserResModel..dart';
import 'package:delivery_mvp_app/data/Model/forgotSendOTPBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/forgotSentOTPRestModel.dart';
import 'package:delivery_mvp_app/data/Model/getDeliveryHistoryResModel..dart';
import 'package:delivery_mvp_app/data/Model/getDistanceBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/getDistanceResModel.dart';
import 'package:delivery_mvp_app/data/Model/getProfileModel.dart';
import 'package:delivery_mvp_app/data/Model/loginBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/loginResModel.dart';
import 'package:delivery_mvp_app/data/Model/loginVerifyBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/loginVerifyResModel.dart';
import 'package:delivery_mvp_app/data/Model/registerBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/registerResModel.dart';
import 'package:delivery_mvp_app/data/Model/updateUserProfileBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/updateUserProfileResModel.dart';
import 'package:delivery_mvp_app/data/Model/uploadImageResModel.dart';
import 'package:delivery_mvp_app/data/Model/verifyOrResetPassBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/verifyOrResetPassResModel.dart';
import 'package:delivery_mvp_app/data/Model/verifyRegisterBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/verifyRegisterResModel.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import '../../data/Model/AddAddressModel.dart';
import '../../data/Model/CancelOrderModel.dart';
import '../../data/Model/DeleteAddressModel.dart';
import '../../data/Model/GetAddressResponseModel.dart';
import '../../data/Model/GetDeliveryByIdResModel.dart';
import '../../data/Model/RatingResponseModel.dart';
import '../../data/Model/SubmitRatingModel.dart';

part 'api.state.g.dart';

//@RestApi(baseUrl: "https://weloads.com/api")
@RestApi(baseUrl: "http://192.168.1.43:4567/api") // local url
abstract class APIStateNetwork {
  factory APIStateNetwork(Dio dio, {String baseUrl}) = _APIStateNetwork;

  @POST("/v1/user/reviewRating")
  Future<RatingResponseModel> reviewRating(@Body() SubmitRatingRequest body);

  @GET("/v1/user/getAllAddresses")
  Future<GetAddressRsponseModel> getAllAddresses();

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

  @GET("/v1/user/getProfile")
  Future<GetProfileModel> fetchProfile();

  @POST("/v1/user/getDistance")
  Future<GetDistanceResModel> getDistance(@Body() GetDistanceBodyModel body);

  @POST("/v1/user/bookInstantDelivery")
  Future<BookInstantDeliveryResModel> bookInstantDelivery(
    @Body() BookInstantDeliveryBodyModel body,
  );

  @POST("/v1/user/deliveryCancelledByUser")
  Future<DriverCancelDeliveryResModel> deliveryCancelledByUser(
    @Body() CancelOrderModel body,
  );

  @POST("/v1/user/getDeliveryHistory")
  Future<GetDeliveryHistoryResModel> getDeliveryHistory();

  @GET("/v1/user/getDeliveryById")
  Future<GetDeliveryByIdResModel> getDeliveryById(
    @Query("deliveryId") String deliveryId,
  );

  @POST("/v1/user/addAddress")
  Future<HttpResponse<dynamic>> addAddress(@Body() AddAddressModel body);

  @POST("/v1/user/updateAddress")
  Future<HttpResponse<dynamic>> updateAddress(
    @Body() UpdateAddressBodyModel body,
  );

  @POST("/v1/user/deleteAddress")
  Future<HttpResponse<dynamic>> deleteAddress(@Body() DeleteAddressModel body);

  @MultiPart()
  @POST("/v1/uploadImage")
  Future<UploadImageReModel> uploadImage(@Part(name: "file") File file);

  @PUT("/v1/user/updateCostumerProfile")
  Future<UpdateUserProfileResModel> updateCutomerProfile(
    @Body() UpdateUserProfileBodyModel body,
  );
}
