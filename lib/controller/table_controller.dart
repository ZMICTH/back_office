import 'dart:async';

import 'package:back_office/model/reserve_table_model.dart';
import 'package:back_office/services/table_service.dart';

class ReserveTableHistoryController {
  List<ReserveTableHistory> ReserveTableHistories = List.empty();
  List<TableCatalog> TableCatalogs = List.empty();
  final TableCatalogFirebaseService service;

  StreamController<bool> onSyncController = StreamController();
  Stream<bool> get onSync => onSyncController.stream;

  ReserveTableHistoryController(this.service);

  Future<List<TableCatalog>> fetchTableCatalog() async {
    print("fetchTableCatalog was: ${TableCatalogs}");
    onSyncController.add(true);
    TableCatalogs = await service.getAllTableCatalog();
    onSyncController.add(false);
    return TableCatalogs;
  }

  Future<List<ReserveTableHistory>> fetchReserveTableHistory() async {
    print("fetchReserveTableHistory was: ${ReserveTableHistories}");
    onSyncController.add(true);
    ReserveTableHistories = await service.getAllReserveTableHistory();
    onSyncController.add(false);
    return ReserveTableHistories;
  }
}
