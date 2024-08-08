import 'package:back_office/component/drawer.dart';
import 'package:back_office/controller/bill_order_controller.dart';
import 'package:back_office/controller/reserve_ticket_controller.dart';
import 'package:back_office/controller/table_controller.dart';
import 'package:back_office/model/bill_order_model.dart';
import 'package:back_office/model/login_model.dart';
import 'package:back_office/model/reserve_table_model.dart';
import 'package:back_office/model/reserve_ticket_model.dart';
import 'package:back_office/services/bill_historyservice.dart';
import 'package:back_office/services/reserve_ticket_service.dart';
import 'package:back_office/services/table_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NewHomePage extends StatefulWidget {
  @override
  _NewHomePageState createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  late ReserveTableHistoryController reservetablehistorycontroller =
      ReserveTableHistoryController(TableCatalogFirebaseService());
  late TicketConcertController ticketconcertcontroller =
      TicketConcertController(TicketConcertFirebaseService());

  void _refreshPage() {
    fetchBillOrders();
    _loadReserveTableHistory();
  }

  late BillHistoryController billHistoryController;
  bool isLoading = true;
  List<OrderHistories> orders = [];
  double totalPayment = 0.00;
  bool isChecked = false;
  String partnerId = '';
  List<ReserveTableHistory> reservetables = [];
  List<BookingTicket> reserveticket = [];
  String? selectedTable;

  String formatDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat.yMMMMd().add_jm();
    return formatter.format(dateTime);
  }

  @override
  void initState() {
    super.initState();
    billHistoryController = BillHistoryController(BillHistoryFirebaseService());
    fetchBillOrders();
    reservetablehistorycontroller =
        ReserveTableHistoryController(TableCatalogFirebaseService());
    _loadReserveTableHistory();
    ticketconcertcontroller =
        TicketConcertController(TicketConcertFirebaseService());
    _loadReservationTicketHistory();
  }

  Future<void> fetchBillOrders() async {
    try {
      final userId =
          Provider.of<MemberUserModel>(context, listen: false).memberUser!.id;
      List<OrderHistories> fetchedOrders =
          await billHistoryController.fetchBillOrder();

      List<OrderHistories> filteredOrders =
          fetchedOrders.where((order) => order.partnerId == userId).toList();

      Provider.of<BillOrderProvider>(context, listen: false)
          .setUnBillOrder(filteredOrders);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      print("Failed to fetch bill orders: $e");
    }
  }

  void _loadReserveTableHistory() async {
    try {
      final userId =
          Provider.of<MemberUserModel>(context, listen: false).memberUser!.id;
      reservetables =
          await reservetablehistorycontroller.fetchReserveTableHistory();

      reservetables = reservetables
          .where((reserve) => reserve.partnerId == userId)
          .toList();
      Provider.of<ReserveTableProvider>(context, listen: false)
          .setReserveTable(reservetables);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading data: $e');
    }
  }

  void _loadReservationTicketHistory() async {
    try {
      final userId =
          Provider.of<MemberUserModel>(context, listen: false).memberUser!.id;

      reserveticket = await ticketconcertcontroller.fetchReservationTicket();
      reserveticket = reserveticket
          .where((reserve) => reserve.partnerId == userId)
          .toList();
      Provider.of<ReservationTicketProvider>(context, listen: false)
          .setAllReservationTicket(reserveticket);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MemberUserModel>(builder: (context, userModel, child) {
      final memberUser = userModel.memberUser;

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          title: Text("Home page - Welcome, ${memberUser!.partnerName}!"),
          foregroundColor: Theme.of(context).colorScheme.surface,
          titleTextStyle: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.surface,
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              icon: const Icon(Icons.account_circle_sharp),
              iconSize: 40,
            ),
          ],
        ),
        drawer: AppDrawer(),
        body: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            buildTableLabels(context, memberUser!.tableLabels),
                      ),
                    ),
                  ),
                  Divider(color: Colors.grey[400]),
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Expanded(
                          child: Consumer<BillOrderProvider>(
                            builder: (context, billOrderProvider, child) {
                              if (billOrderProvider.unpaidBillOrder.isEmpty) {
                                return Center(child: Text("No new orders"));
                              }

                              List<OrderHistories> newOrders = billOrderProvider
                                  .unpaidBillOrder
                                  .where((order) => order.orders
                                      .any((item) => item['delivered'] == null))
                                  .toList();

                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "New Orders",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: newOrders.length,
                                        itemBuilder: (context, index) {
                                          return buildOrderDetails(
                                              newOrders[index]);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
            VerticalDivider(),
            Expanded(
              flex: 2,
              child: selectedTable == null
                  ? Center(child: Text("Select a table to view details"))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "All order in table",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  showCheckOutDialog();
                                },
                                child: Text(
                                  "Check Out",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: buildTableOrderDetails(selectedTable!),
                        ),
                      ],
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _refreshPage,
          child: Icon(Icons.refresh),
        ),
      );
    });
  }

  List<Widget> buildTableLabels(
      BuildContext context, List<Map<String, dynamic>> tableLabels) {
    var reserveTableProvider = Provider.of<ReserveTableProvider>(context);
    var reservationTicketProvider =
        Provider.of<ReservationTicketProvider>(context);

    List<ReserveTableHistory> allReserveTable =
        reserveTableProvider.allReserveTable;
    List<BookingTicket> allReservationTickets =
        reservationTicketProvider.reservationtickets;

    List<Widget> tableWidgets = [];

    final today = DateTime.now();
    bool isEventDay = reservationTicketProvider.AllTickets.any((ticket) =>
        ticket.eventDate.year == today.year &&
        ticket.eventDate.month == today.month &&
        ticket.eventDate.day == today.day);

    for (var table in tableLabels) {
      String label = table['label'] ?? 'Unknown';
      int total = table['totaloftable'] ?? 0;
      for (int i = 1; i <= total; i++) {
        bool isReserved = allReserveTable.any((reservation) =>
            reservation.tableNo == '$label $i' &&
            reservation.checkIn &&
            reservation.checkOut != true);

        // Check if the table is reserved for an event
        bool isEventReserved = isEventDay &&
            allReservationTickets.any((reservation) =>
                reservation.tableNo == '$label $i' &&
                reservation.checkIn &&
                reservation.checkOut != true);

        tableWidgets.add(
          GestureDetector(
            onTap: () {
              setState(() {
                selectedTable = '$label $i';
                print(selectedTable);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: isReserved || isEventReserved
                    ? Colors.yellow
                    : Colors.white,
                border: Border.all(
                    color: isReserved || isEventReserved
                        ? Colors.orange
                        : Colors.blueAccent),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    '$label $i',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (isReserved)
                    Text(
                      'กำลังใช้งาน',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                  if (isEventReserved)
                    Text(
                      'กำลังใช้งานอีเว้นท์',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
        );
      }
    }
    return tableWidgets;
  }

  Widget buildTableOrderDetails(String tableNo) {
    DateTime today = DateTime.now();
    List<OrderHistories> tableOrders =
        Provider.of<BillOrderProvider>(context, listen: false)
            .unpaidBillOrder
            .where((order) =>
                order.tableNo == tableNo &&
                order.billingTime.year == today.year &&
                order.billingTime.month == today.month &&
                order.billingTime.day == today.day)
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: tableOrders.length,
            itemBuilder: (context, index) {
              final order = tableOrders[index];
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildOrderHeader(order),
                      ...order.orders.map((billOrder) {
                        return buildOrderItem(billOrder);
                      }).toList(),
                      buildOrderFooter(order),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildOrderDetails(OrderHistories order) {
    return InkWell(
      onTap: () {
        showOrderDetailsDialog(context, order);
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildOrderHeader(order),
              ...order.orders.map((billOrder) {
                return buildOrderItem(billOrder);
              }).toList(),
              buildOrderFooter(order),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOrderHeader(OrderHistories order) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy - HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Table: ${order.tableNo}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Order Time: ${formatter.format(order.billingTime)}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "Payment Status: ${order.paymentStatus ? 'Paid' : 'Pending'}",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: order.paymentStatus ? Colors.green : Colors.red),
        ),
        Divider(color: Colors.grey[400]),
      ],
    );
  }

  Widget buildOrderItem(Map<String, dynamic> billOrder) {
    final numberFormat = NumberFormat("#,##0", "en_US");
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "${billOrder['quantity']} x ${billOrder['name']} (${billOrder['item']} ${billOrder['unit']})",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Text(
            "${numberFormat.format(billOrder['price'])} THB",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget buildOrderFooter(OrderHistories order) {
    final numberFormat = NumberFormat("#,##0", "en_US");
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Amount before VAT: ${numberFormat.format(order.totalPrice / 1.07)} THB",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              Text(
                "VAT(7%): ${numberFormat.format(order.totalPrice - (order.totalPrice / 1.07))} THB",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              SizedBox(height: 3),
              Text(
                "Total: ${numberFormat.format(order.totalPrice)} THB",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void showOrderDetailsDialog(BuildContext context, OrderHistories order) {
    final numberFormat = NumberFormat("#,##0", "en_US");
    List<bool> checkboxStates =
        List<bool>.generate(order.orders.length, (_) => false);
    bool isAllSelected = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order Details",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.close),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    Text("Table: ${order.tableNo}",
                        style: TextStyle(fontSize: 20)),
                    Text("Bill Time: ${formatDate(order.billingTime)}",
                        style: TextStyle(fontSize: 20)),
                    Divider(),
                    CheckboxListTile(
                      title: Text(
                        "Select All",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      value: isAllSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          isAllSelected = value!;
                          for (int i = 0; i < checkboxStates.length; i++) {
                            checkboxStates[i] = value;
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    ...order.orders.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var item = entry.value;
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: CheckboxListTile(
                          value: checkboxStates[idx],
                          onChanged: (bool? value) {
                            setState(() {
                              checkboxStates[idx] = value!;
                              isAllSelected =
                                  checkboxStates.every((element) => element);
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            "${item['quantity']} x ${item['name']} (${item['item']} ${item['unit']}) - ${item['price']} THB",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 10),
                    Divider(),
                    Text(
                      "Amount before VAT: ${numberFormat.format(order.totalPrice / 1.07)} THB",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    Text(
                      "VAT(7%): ${numberFormat.format(order.totalPrice - (order.totalPrice / 1.07))} THB",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    Text(
                      "Total: ${numberFormat.format(order.totalPrice)} THB",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        child: Text('Confirm Deliver Order',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          updateOrderInDatabase(order, checkboxStates);
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Cancel Order',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.red,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          cancelOrderInDatabase(order, checkboxStates);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void updateOrderInDatabase(
      OrderHistories order, List<bool> checkboxStates) async {
    try {
      for (int i = 0; i < order.orders.length; i++) {
        if (checkboxStates[i]) {
          order.orders[i]['delivered'] = true;
        }
      }

      await FirebaseFirestore.instance
          .collection('order_history')
          .doc(order.id)
          .update(order.toJson());
      print('Order updated successfully!');
    } catch (e) {
      print('Error updating order: $e');
    }
  }

  void cancelOrderInDatabase(
      OrderHistories order, List<bool> checkboxStates) async {
    try {
      for (int i = 0; i < order.orders.length; i++) {
        if (checkboxStates[i]) {
          order.orders[i]['delivered'] = false;
        }
      }

      await FirebaseFirestore.instance
          .collection('order_history')
          .doc(order.id)
          .update(order.toJson());
      print('Order cancellation updated successfully!');
    } catch (e) {
      print('Error updating order cancellation: $e');
    }
  }

  void showCheckOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Check Out',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              )),
          content: Text('Are you sure you want to check out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            TextButton(
              onPressed: () async {
                await checkOutTable(selectedTable!);
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Check Outs successfully!',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('Yes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ],
        );
      },
    );
  }

  Future<void> checkOutTable(String tableNo) async {
    try {
      // Find all reservations for the selected table
      var tableReservations =
          Provider.of<ReserveTableProvider>(context, listen: false)
              .allReserveTable
              .where((reservation) => reservation.tableNo == tableNo)
              .toList();

      var eventReservations =
          Provider.of<ReservationTicketProvider>(context, listen: false)
              .reservationtickets
              .where((reservation) => reservation.tableNo == tableNo)
              .toList();

      for (var reservation in tableReservations) {
        await FirebaseFirestore.instance
            .collection('reservation_table')
            .doc(reservation.id)
            .update({
          'checkOut': true,
          'checkOutTime': Timestamp.now(),
        });
      }

      for (var reservation in eventReservations) {
        await FirebaseFirestore.instance
            .collection('reservation_ticket')
            .doc(reservation.id)
            .update({
          'checkOut': true,
          'checkOutTime': Timestamp.now(),
        });
      }

      // Refresh the data
      _refreshPage();
    } catch (e) {
      print('Error checking out table: $e');
    }
  }
}
