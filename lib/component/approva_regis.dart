import 'package:back_office/model/login_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ApprovalPartnershipScreen extends StatefulWidget {
  final PartnerUser partner;

  ApprovalPartnershipScreen({required this.partner});

  @override
  State<ApprovalPartnershipScreen> createState() =>
      _ApprovalPartnershipScreenState();
}

class _ApprovalPartnershipScreenState extends State<ApprovalPartnershipScreen> {
  final _formKey = GlobalKey<FormState>();
  late double _commissionRate;

  @override
  void initState() {
    super.initState();
    _commissionRate = 0.0;
  }

  Future<void> _approvePartner() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await FirebaseFirestore.instance
          .collection('partner')
          .doc(widget.partner.id)
          .update({
        'userStatus': 'active',
        'commissionRate': _commissionRate,
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Approval successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat("#,##0", "en_US");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text('อนุมัติพาร์ทเนอร์'),
        titleTextStyle: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'รายละเอียดพาร์ทเนอร์',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'ชื่อ: ${widget.partner.partnerName}',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Tax-id: ${widget.partner.taxId}',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'อีเมล: ${widget.partner.emailUser}',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'เบอร์โทรศัพท์: ${widget.partner.partnerPhone}',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'จำนวนที่นั่ง: ${widget.partner.totalSeats} ที่นั่ง',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'ประเภทโต๊ะที่ลงทะเบียน:',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  ...widget.partner.tableLabels.map((table) {
                    return Text(
                      'ชื่อเรียก ${table['label']} ทั้งหมด: ${table['totaloftable']} โต๊ะ, จำนวน ${table['numberofchairs']} ที่นั่ง, ราคาจองล่วงหน้า ${numberFormat.format(table['tablePrices'])} บาท',
                      style: TextStyle(fontSize: 22),
                    );
                  }).toList(),
                  SizedBox(height: 5),
                  Text(
                    'สถานะ: ${widget.partner.userStatus}',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _launchURL(widget.partner.fileURL),
                    child: Text(
                      'View Partner Document',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Commission Rate',
                      labelStyle: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a commission rate';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _commissionRate = double.parse(value!);
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _approvePartner,
                    child: Text(
                      'อนุมัติการเป็นสมาชิก',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
