import 'package:back_office/homepage.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getUserCount() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    return snapshot.docs.length;
  }

  Future<int> getPartnerCount() async {
    QuerySnapshot snapshot = await _firestore.collection('partners').get();
    return snapshot.docs.length;
  }
}

class AdminHomePage extends StatefulWidget {
  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final DashboardService _dashboardService = DashboardService();

  late Future<int> _userCount;
  late Future<int> _partnerCount;
  final String _currentDate =
      DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _userCount = _dashboardService.getUserCount();
    _partnerCount = _dashboardService.getPartnerCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 44, 83, 96),
        title: Text('ภาพรวมระบบ'),
        titleTextStyle: TextStyle(
          color: Color.fromARGB(255, 252, 194, 95),
          fontSize: 20.0,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FutureBuilder(
                future: Future.wait([_userCount, _partnerCount]),
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
                    return _buildPieChart(userCount, partnerCount);
                  }
                },
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // ListTile(
                //   leading: Icon(Icons.book),
                //   title: Text('รายการจองทั้งหมด'),
                //   onTap: () {
                //     Navigator.pushNamed(context, '/26');
                //   },
                //   trailing: Icon(Icons.arrow_forward_ios),
                //   shape: RoundedRectangleBorder(
                //     side: BorderSide(
                //         color: Color.fromARGB(255, 146, 100, 15), width: 1),
                //     borderRadius: BorderRadius.circular(5),
                //   ),
                // ),
                // ListTile(
                //   leading: Icon(Icons.people),
                //   title: Text('รายชื่อผู้รับจัดงาน'),
                //   onTap: () {
                //     // Handle the tap
                //   },
                //   trailing: Icon(Icons.arrow_forward_ios),
                //   shape: RoundedRectangleBorder(
                //     side: BorderSide(
                //         color: Color.fromARGB(255, 146, 100, 15), width: 1),
                //     borderRadius: BorderRadius.circular(5),
                //   ),
                // ),
                ListTile(
                  leading: Icon(Icons.event),
                  title: Text('ข้อมูลงาน Event ในระบบทั้งหมด'),
                  onTap: () {
                    // Handle the tap
                  },
                  trailing: Icon(Icons.arrow_forward_ios),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: Color.fromARGB(255, 146, 100, 15), width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.search),
                  title: Text('รายชื่อและข้อมูลผู้ค้นหาผู้จัด'),
                  onTap: () {
                    // Handle the tap
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin'), // Hidden item
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewHomePage()),
            );
          }
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminHomePage()),
            );
          }
        },
      ),
    );
  }

  Widget _buildPieChart(int userCount, int partnerCount) {
    return Column(
      children: [
        Text(
          _currentDate,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.3,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  color: Color.fromARGB(255, 44, 83, 96),
                  value: userCount.toDouble(),
                  title: 'Users\n$userCount',
                  radius: 100,
                  titleStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                PieChartSectionData(
                  color: Color.fromARGB(255, 252, 194, 95),
                  value: partnerCount.toDouble(),
                  title: 'Organizers\n$partnerCount',
                  radius: 100,
                  titleStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
      ],
    );
  }
}
