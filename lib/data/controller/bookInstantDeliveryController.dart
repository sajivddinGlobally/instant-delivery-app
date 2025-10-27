import 'dart:developer';
import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/bookInstantDeliveryResModel.dart';
import 'package:delivery_mvp_app/data/Model/bookInstantdeliveryBodyModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BookInstantDeliveryNotifier
    extends StateNotifier<AsyncValue<BookInstantDeliveryResModel>> {
  BookInstantDeliveryNotifier() : super(AsyncValue.loading());

  //   Future<void> bookInstantDelivery(BookInstantDeliveryBodyModel body) async {
  //     try {
  //       state = AsyncValue.loading();
  //       final service = APIStateNetwork(callPrettyDio());
  //       final response = await service.bookInstantDelivery(body);
  //       state = AsyncValue.data(response);

  //       log(response.message);

  //       Fluttertoast.showToast(msg: response.message);
  //     } catch (e, st) {
  //       state = AsyncValue.error(e, st);
  //       log("${e.toString()} / ${st.toString()}");
  //       Fluttertoast.showToast(msg: e.toString());
  //     }
  //   }
  // }
  Future<BookInstantDeliveryResModel?> bookInstantDelivery(
    BookInstantDeliveryBodyModel body,
  ) async {
    try {
      state = AsyncValue.loading();
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.bookInstantDelivery(body);
      state = AsyncValue.data(response);

      log(response.message);
      Fluttertoast.showToast(msg: response.message);

      // ✅ Return the response so UI can use it
      return response;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      log("${e.toString()} / ${st.toString()}");
      Fluttertoast.showToast(msg: e.toString());
      return null; // ✅ Return null on error
    }
  }
}

final bookDeliveryProvider =
    StateNotifierProvider<
      BookInstantDeliveryNotifier,
      AsyncValue<BookInstantDeliveryResModel>
    >((ref) => BookInstantDeliveryNotifier());
