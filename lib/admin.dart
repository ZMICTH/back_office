import 'package:back_office/component/approva_regis.dart';
import 'package:back_office/controller/bill_order_controller.dart';
import 'package:back_office/controller/login_controller.dart';
import 'package:back_office/controller/reserve_ticket_controller.dart';
import 'package:back_office/controller/table_controller.dart';
import 'package:back_office/model/bill_order_model.dart';

import 'package:back_office/model/login_model.dart';
import 'package:back_office/model/reserve_table_model.dart';
import 'package:back_office/model/reserve_ticket_model.dart';
import 'package:back_office/services/bill_historyservice.dart';
import 'package:back_office/services/login_service.dart';
import 'package:back_office/services/reserve_ticket_service.dart';
import 'package:back_office/services/table_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getUserCount() async {
    QuerySnapshot snapshot = await _firestore.collection('User').get();
    return snapshot.docs.length;
  }

  Future<int> getActivePartnerCount() async {
    QuerySnapshot snapshot = await _firestore
        .collection('partner')
        .where('role', isEqualTo: "partner")
        .where('userStatus', isEqualTo: "active")
        .get();
    return snapshot.docs.length;
  }

  Future<int> getInactivePartnerCount() async {
    QuerySnapshot snapshot = await _firestore
        .collection('partner')
        .where('role', isEqualTo: "partner")
        .where('userStatus', isEqualTo: "Inactive")
        .get();
    return snapshot.docs.length;
  }
}

class AdminHomePage extends StatefulWidget {
  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final DashboardService _dashboardService = DashboardService();
  late LoginController logincontroller =
      LoginController(LoginFirebaseService());
  late ReserveTableHistoryController reservetablehistorycontroller =
      ReserveTableHistoryController(TableCatalogFirebaseService());
  late TicketConcertController ticketconcertcontroller =
      TicketConcertController(TicketConcertFirebaseService());
  late BillHistoryController billHistoryController;
  bool isLoading = true;
  bool showCard = false; // ตัวแปรสถานะสำหรับการแสดงหรือซ่อน Card

  late Future<int> _userCount;
  late Future<int> _partnerCount;
  late Future<int> _inactivePartnerCount;

  List<PartnerUser> partnerships = [];
  List<ReserveTableHistory> reservetables = [];
  List<BookingTicket> reserveticket = [];
  List<OrderHistories> orders = [];

  void _refreshPage() {
    _loadApprovalPartnership();
    _loadReserveTableHistory();
    _userCount;
    _partnerCount;
  }

  final String _currentDate =
      DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _userCount = _dashboardService.getUserCount();
    _partnerCount = _dashboardService.getActivePartnerCount();
    _inactivePartnerCount = _dashboardService.getInactivePartnerCount();
    logincontroller = LoginController(LoginFirebaseService());
    _loadApprovalPartnership();
    reservetablehistorycontroller =
        ReserveTableHistoryController(TableCatalogFirebaseService());
    ticketconcertcontroller =
        TicketConcertController(TicketConcertFirebaseService());
    billHistoryController = BillHistoryController(BillHistoryFirebaseService());
    _loadReserveTableHistory();
  }

  void _loadApprovalPartnership() async {
    try {
      partnerships = await logincontroller.fetchPartnerUser();

      Provider.of<MemberUserModel>(context, listen: false)
          .setPartnerDetail(partnerships);
      Provider.of<MemberUserModel>(context, listen: false)
          .selectInactivePartner();
      setState(() => isLoading = false);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading data: $e');
    }
  }

  void _loadReserveTableHistory() async {
    try {
      // Fetch tables from Firebase
      reservetables =
          await reservetablehistorycontroller.fetchReserveTableHistory();
      reserveticket = await ticketconcertcontroller.fetchReservationTicket();
      orders = await billHistoryController.fetchBillOrder();

      Provider.of<ReservationTicketProvider>(context, listen: false)
          .setAllReservationTicket(reserveticket);

      Provider.of<ReserveTableProvider>(context, listen: false)
          .setReserveTable(reservetables);

      Provider.of<BillOrderProvider>(context, listen: false)
          .setUnBillOrder(orders);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text('ภาพรวมระบบ'),
        titleTextStyle: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.surface,
        ),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              print('logout is call');
              Provider.of<MemberUserModel>(context, listen: false)
                  .clearMemberUser();
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout),
            iconSize: 40,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: Future.wait(
                  [_userCount, _partnerCount, _inactivePartnerCount]),
              builder: (context, AsyncSnapshot<List<int>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Icon(Icons.error, color: Colors.red));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data available'));
                } else {
                  int userCount = snapshot.data![0];
                  int partnerCount = snapshot.data![1];
                  int inactivePartnerCount = snapshot.data![2];
                  return _buildCountContainers(
                      userCount, partnerCount, inactivePartnerCount);
                }
              },
            ),
            SizedBox(height: 30),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(Icons.event),
                  title: Text(
                    'คำขออนุมัติเป็นพาร์ทเนอร์',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      showCard = !showCard; // สลับการแสดงผลของ Card
                    });
                  },
                  trailing: Icon(Icons.arrow_forward_ios),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Color.fromARGB(255, 146, 100, 15), width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                SizedBox(height: 20),
                if (showCard)
                  Consumer<MemberUserModel>(
                    builder: (context, memberUserModel, child) {
                      if (memberUserModel.selectedInactivePartner != null &&
                          memberUserModel.selectedInactivePartner!.userStatus ==
                              "Inactive") {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ApprovalPartnershipScreen(
                                  partner:
                                      memberUserModel.selectedInactivePartner!,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'รายละเอียดพาร์ทเนอร์',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'ชื่อ: ${memberUserModel.selectedInactivePartner!.partnerName}',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'อีเมล: ${memberUserModel.selectedInactivePartner!.emailUser}',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'เบอร์โทรศัพท์: ${memberUserModel.selectedInactivePartner!.partnerPhone}',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'สถานะ: ${memberUserModel.selectedInactivePartner!.userStatus}',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
                SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.book),
                  title: Text(
                    'รายงานผู้ใช้งานระบบ',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/adminreport');
                  },
                  trailing: Icon(Icons.arrow_forward_ios),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Color.fromARGB(255, 146, 100, 15), width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshPage,
        child: Icon(Icons.refresh),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   type: BottomNavigationBarType.fixed,
      //   items: [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      //     BottomNavigationBarItem(
      //         icon: Icon(Icons.admin_panel_settings),
      //         label: 'Admin'), // Add second item
      //   ],
      //   onTap: (index) {
      //     if (index == 0) {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (context) => AdminHomePage()),
      //       );
      //     }
      //     if (index == 1) {
      //       // Handle Admin tab tap
      //     }
      //   },
      // ),
    );
  }

  Widget _buildCountContainers(
      int userCount, int partnerCount, int inactivePartnerCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          height: 100,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 252, 194, 95),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer User : ',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              Text(
                '$userCount',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
          height: 100,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 192, 57, 43),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Request to Join : ',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                '$inactivePartnerCount',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
        Container(
          height: 100,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 44, 83, 96),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Partner : ',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                '$partnerCount',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
