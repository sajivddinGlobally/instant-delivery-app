import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/getTicketResModel.dart';
import 'package:delivery_mvp_app/data/Model/ticketDetailsBodyModel.dart';
import 'package:delivery_mvp_app/data/Model/ticketDetailsResModel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getTicketListController =
    FutureProvider.autoDispose<GetTicketListResModel>((ref) async {
      final service = APIStateNetwork(callPrettyDio());
      return await service.getTicketList();
    });

final ticketDetailsController =
    FutureProvider.family<GetTicketDetailsResModel, String>((ref, id) async {
      final service = APIStateNetwork(callPrettyDio());
      final body = TicketDetailsBodyModel(id: id);
      return await service.ticketDetails(body);
    });
