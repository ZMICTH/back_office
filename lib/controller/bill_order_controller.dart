import 'dart:async';
import 'package:back_office/model/bill_order_model.dart';
import 'package:back_office/services/bill_historyservice.dart';

class BillHistoryController {
  List<OrderHistories> OrderHistory = List.empty();
  final BillHistoryService service;

  StreamController<bool> onSyncController = StreamController<bool>();
  Stream<bool> get onSync => onSyncController.stream;
  BillHistoryController(this.service);

  Future<List<OrderHistories>> fetchBillOrder() async {
    print("fetchBillOrder was: ${OrderHistory}");
    onSyncController.add(true);
    OrderHistory = await service.getAllBillOrders();
    onSyncController.add(false);
    return OrderHistory;
  }
}
