import 'package:delivery_mvp_app/data/Model/registerBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/registerResModel.dart';
import 'package:delivery_mvp_app/data/Model/verifyRegisterBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/verifyRegisterResModel.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
part 'api.state.g.dart';

@RestApi(baseUrl: "http://192.168.1.43:4567")
abstract class APIStateNetwork {
  factory APIStateNetwork(Dio dio, {String baseUrl}) = _APIStateNetwork;

  @POST("/api/v1/user/register")
  Future<RegisterResModel> userRegister(@Body() RegisterBodyModel body);

  @POST("/api/v1/user/registerVerify")
  Future<VerifyRegisterResModel> verifyRegister(
    @Body() VerifyRegisterBodyModel body,
  );
}
