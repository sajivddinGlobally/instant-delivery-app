import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:riverpod/riverpod.dart';
import 'package:retrofit/retrofit.dart';

import '../Model/GetAddressResponseModel.dart';

final getAddressProvider = FutureProvider<GetAddressRsponseModel>((ref) async {
  final service = APIStateNetwork(callPrettyDio());
  return await service.getAllAddresses();
});
