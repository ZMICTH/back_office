import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderHistories {
  String id = "";
  List<Map<String, dynamic>> orders;
  double totalPrice;
  double totalQuantity;
  String partnerId;
  DateTime billingTime;
  bool paymentStatus;
  String userNickName;
  String tableNo;
  String roundtable;

  OrderHistories({
    this.id = "",
    required this.orders,
    required this.totalPrice,
    required this.totalQuantity,
    required this.partnerId,
    required this.billingTime,
    required this.paymentStatus,
    required this.userNickName,
    required this.tableNo,
    required this.roundtable,
  });

  factory OrderHistories.fromJson(Map<String, dynamic> json) {
    print(json);
    return OrderHistories(
      id: json['id'] as String,
      orders: (json['orders'] as List<dynamic>? ?? [])
          .map<Map<String, dynamic>>(
              (item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      totalQuantity: json['totalQuantity'] ?? 0,
      partnerId: json['partnerId'] as String,
      billingTime:
          (json['billingTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentStatus: json['paymentStatus'] as bool? ?? false,
      userNickName: json['userNickName'] as String? ?? "",
      tableNo: json['tableNo'] as String? ?? "",
      roundtable: json['roundtable'] as String? ?? "",
    );
  }

  factory OrderHistories.fromSnapshot(DocumentSnapshot snapshot) {
    var json = snapshot.data() as Map<String, dynamic>;
    return OrderHistories(
      id: snapshot.id,
      orders: (json['orders'] as List)
          .map((item) => Map<String, dynamic>.from(item))
          .toList(),
      totalPrice: json['totalPrice'],
      totalQuantity: json['totalQuantity'],
      partnerId: json['partnerId'] as String,
      billingTime: (json['billingTime'] as Timestamp).toDate(),
      paymentStatus: json['paymentStatus'],
      userNickName: json['userNickName'],
      tableNo: json['tableNo'] as String,
      roundtable: json['roundtable'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billingTime': billingTime,
      'totalPrice': totalPrice,
      'totalQuantity': totalQuantity,
      'paymentStatus': paymentStatus,
      'orders': orders
          .map((order) => {
                'delivered': order['delivered'],
                'name': order['name'],
                'price': order['price'],
                'item': order['item'],
                'unit': order['unit'],
                'type': order['type'],
                'quantity': order['quantity'],
              })
          .toList(),
      'userNickName': userNickName,
      'partnerId': partnerId,
      'tableNo': tableNo,
      'roundtable': roundtable,
    };
  }
}

class AllOrderHistory {
  final List<OrderHistories> orderHistories;

  AllOrderHistory(this.orderHistories);

  factory AllOrderHistory.fromJson(List<dynamic> json) {
    List<OrderHistories> orderHistories =
        json.map((item) => OrderHistories.fromJson(item)).toList();
    return AllOrderHistory(orderHistories);
  }

  factory AllOrderHistory.fromSnapshot(QuerySnapshot qs) {
    List<OrderHistories> orderHistories = qs.docs.map((DocumentSnapshot ds) {
      Map<String, dynamic> dataWithId = ds.data() as Map<String, dynamic>;
      dataWithId['id'] = ds.id;
      return OrderHistories.fromJson(dataWithId);
    }).toList();
    return AllOrderHistory(orderHistories);
  }

  Map<String, dynamic> toJson() {
    return {
      'orderHistories':
          orderHistories.map((reservetable) => reservetable.toJson()).toList(),
    };
  }
}

class BillOrderProvider extends ChangeNotifier {
  List<OrderHistories> _unpaidBillOrder = [];
  List<OrderHistories> get unpaidBillOrder => _unpaidBillOrder;

  // List<OrderHistories> _allOrderHistory = [];
  // List<OrderHistories> get allOrderHistory => _allOrderHistory;

  // void setBillOrder(List<OrderHistories> billingOrder) {
  //   _allOrderHistory = billingOrder;
  //   notifyListeners();
  // }

  void clearBillingOrder() {
    // _allOrderHistory.clear();
    _unpaidBillOrder.clear();
    notifyListeners();
  }

  void setUnBillOrder(List<OrderHistories> billingOrder) {
    _unpaidBillOrder = billingOrder;
    notifyListeners();
  }

  List<Map<String, dynamic>> get foodSalesData {
    return _unpaidBillOrder
        .expand((order) => order.orders.map((item) => {
              'Date': order.billingTime.toString(),
              'Table No.': order.tableNo,
              'Round Table': order.roundtable,
              'Food Item': item['name'],
              'Product Type': item['type'],
              'Delivery Status': item['delivered'] ? 'Delivered' : 'Cancel',
              'Price Item': item['price'],
              'Item Quantity': item['quantity'],
              'Total Price': order.totalPrice.toInt(),
              'Payment Status': order.paymentStatus ? 'Paid' : 'Unpaid',
            }))
        .toList();
  }
}
