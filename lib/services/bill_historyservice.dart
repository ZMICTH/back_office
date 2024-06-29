import 'package:back_office/model/bill_order_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BillHistoryService {
  Future<List<OrderHistories>> getAllBillOrders();
}

class BillHistoryFirebaseService implements BillHistoryService {
  @override
  Future<List<OrderHistories>> getAllBillOrders() async {
    try {
      QuerySnapshot qs =
          await FirebaseFirestore.instance.collection('order_history').get();
      print("Order History count: ${qs.docs.length}");

      AllOrderHistory OrderHistory = AllOrderHistory.fromSnapshot(qs);
      return OrderHistory.orderHistories;
    } catch (e) {
      print("Error fetching Orders History: $e");
      throw e;
    }
  }
}
