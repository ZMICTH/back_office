import 'dart:async';

import 'package:back_office/model/reserve_table_model.dart';
import 'package:back_office/services/reserve_tabel_service.dart';

class ReserveTableHistoryController {
  List<ReserveTableHistory> ReserveTableHistories = List.empty();

  final ReserveTableHistoryService service;

  StreamController<bool> onSyncController = StreamController();
  Stream<bool> get onSync => onSyncController.stream;

  ReserveTableHistoryController(this.service);

  Future<List<ReserveTableHistory>> fetchReserveTableHistory() async {
    print("fetchReserveTableHistory was: ${ReserveTableHistories}");
    onSyncController.add(true);
    ReserveTableHistories = await service.getAllReserveTableHistory();
    onSyncController.add(false);
    return ReserveTableHistories;
  }
}
