import 'dart:developer';
import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/getDistanceBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/getDistanceResModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GetDistanceNotifier
    extends StateNotifier<AsyncValue<GetDistanceResModel>> {
  GetDistanceNotifier() : super(AsyncValue.loading());

  Future<void> fetchDistance(GetDistanceBodyModel body) async {
    try {
      state = AsyncValue.loading();
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.getDistance(body);
      state = AsyncValue.data(response);
      log(response.message);
      Fluttertoast.showToast(msg: response.message);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      log("${e.toString()}/ ${st.toString()}");
      Fluttertoast.showToast(msg: e.toString());
    }
  }
}

final getDistanceProvider =
    StateNotifierProvider<GetDistanceNotifier, AsyncValue<GetDistanceResModel>>(
      (ref) => GetDistanceNotifier(),
    );
