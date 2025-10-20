import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/getProfileModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getProfileController = FutureProvider.autoDispose<GetProfileModel>((
  ref,
) async {
  final service = APIStateNetwork(callPrettyDio());
  return await service.fetchProfile();
});
