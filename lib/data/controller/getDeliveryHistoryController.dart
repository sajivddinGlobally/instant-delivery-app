import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/getDeliveryHistoryResModel..dart';
import 'package:riverpod/riverpod.dart';

final getDeliveryHistoryController = FutureProvider<GetDeliveryHistoryResModel>(
  (ref) async {
    final service = APIStateNetwork(callPrettyDio());
    return await service.getDeliveryHistory();
  },
);
