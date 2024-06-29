import 'dart:convert';

import 'package:back_office/component/drawer.dart';
import 'package:back_office/controller/reserve_ticket_controller.dart';
import 'package:back_office/model/login_model.dart';
import 'package:back_office/model/reserve_ticket_model.dart';
import 'package:back_office/services/reserve_ticket_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class VerifyTicketPage extends StatefulWidget {
  @override
  State<VerifyTicketPage> createState() => _VerifyTicketPageState();
}

class _VerifyTicketPageState extends State<VerifyTicketPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = false;

  late TicketConcertController ticketconcertcontroller =
      TicketConcertController(TicketConcertFirebaseService());
  bool isLoading = true;

  String? scannedId;
  BookingTicket? scannedReservation;
  String? selectedTableNo;
  String? selectedTotalOfTable;

  final TextEditingController tableNoController = TextEditingController();
  final TextEditingController roundTableController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ticketconcertcontroller =
        TicketConcertController(TicketConcertFirebaseService());
    _loadReservationHistory();
  }

  @override
  void dispose() {
    cameraController.dispose();
    tableNoController.dispose();
    roundTableController.dispose();
    super.dispose();
  }

  Future<void> _loadReservationHistory() async {
    List<BookingTicket> reservations =
        await ticketconcertcontroller.fetchReservationTicket();
    Provider.of<ReservationTicketProvider>(context, listen: false)
        .addAllReserveTickets(reservations);
    setState(() {
      isLoading = false;
    });
  }

  void _onDetect(Barcode barcode, args) {
    if (barcode.rawValue == null) {
      debugPrint('Failed to scan Barcode');
    } else {
      final String code = barcode.rawValue!;
      debugPrint('Barcode found! $code');

      // Parse the scanned QR code to get the doc.id
      final scannedData = code;
      final String scannedId = _extractIdFromScannedData(scannedData);
      setState(() {
        this.scannedId = scannedId;
        // Stop scanning after detecting a QR code
        cameraController.stop();
        // Find the reservation by id from provider
        scannedReservation =
            Provider.of<ReservationTicketProvider>(context, listen: false)
                .getReservationById(scannedId);

        if (scannedReservation != null && scannedReservation!.checkIn) {
          _showAlreadyCheckedInAlert();
        }
      });
    }
  }

  void _showAlreadyCheckedInAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Already Checked In'),
          content: Text('This reservation has already been checked in.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String _extractIdFromScannedData(String scannedData) {
    // Assuming the scanned data is a JSON string and contains an "id" field
    final Map<String, dynamic> jsonData = jsonDecode(scannedData);
    return jsonData['id'];
  }

  void _startScanning() {
    setState(() {
      isScanning = true;
    });
    cameraController.start();
  }

  Future<void> _checkInCustomer() async {
    if (scannedReservation != null) {
      final userId = scannedReservation!.userId;
      final selectedTableLabel = scannedReservation!.selectedTableLabel;

      final tableLabelWithTotal = '$selectedTableLabel $selectedTableNo';
      final partnerId =
          Provider.of<MemberUserModel>(context, listen: false).memberUser!.id;

      // Update the checkIn status in the provider
      Provider.of<ReservationTicketProvider>(context, listen: false)
          .updateCheckInStatus(scannedReservation!.id, true);

      // Update the user's useService in the Firestore collection
      await FirebaseFirestore.instance.collection('User').doc(userId).update({
        'useService': FieldValue.arrayUnion([
          {
            'partnerId': partnerId,
            'date': scannedReservation!.eventDate,
            'roundtable': roundTableController.text,
            'tableNo': tableLabelWithTotal,
          }
        ]),
      });

      // Update the open table in order_history collection with tableNo and roundtable
      // await FirebaseFirestore.instance
      //     .collection('order_history')
      //     .doc(scannedReservation!.id)
      //     .set({
      //   'custId': FieldValue.arrayUnion([
      //     {'userId': userId}
      //   ]),
      //   'getTableTime': DateTime.now(),
      //   'checkOut': false,
      //   'tableNo': tableLabelWithTotal,
      //   'roundtable': roundTableController.text,
      // }, SetOptions(merge: true));

      // Update the reservation_table collection with tableNo and roundtable
      await FirebaseFirestore.instance
          .collection('reservation_ticket')
          .doc(scannedReservation!.id)
          .set({
        'checkIn': true,
        'tableNo': tableLabelWithTotal,
        'roundtable': roundTableController.text,
      }, SetOptions(merge: true));

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Customer checked in successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final memberUserModel = Provider.of<MemberUserModel>(context);
    final tableLabels = memberUserModel.memberUser?.tableLabels ?? [];
    final selectedTableLabel = scannedReservation?.selectedTableLabel;

    // Get the matching table with the selectedTableLabel
    final matchingTable = tableLabels.firstWhere(
        (table) => table['label'] == selectedTableLabel,
        orElse: () => <String, dynamic>{});

    // Get the totalOfTable list if selectedTableLabel matches
    final totalOfTableList = matchingTable.isNotEmpty
        ? List.generate(
            matchingTable['totaloftable'], (index) => (index + 1).toString())
        : [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text("Verify QR-Code Ticket"),
        foregroundColor: Theme.of(context).colorScheme.surface,
        titleTextStyle: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.surface,
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Move between page
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.account_circle_sharp),
            iconSize: 40,
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: SizedBox(
                    height: 400,
                    width: 400,
                    child: Center(
                      child: isScanning
                          ? MobileScanner(
                              controller: cameraController,
                              allowDuplicates: false,
                              onDetect: _onDetect,
                            )
                          : Text('Press the button to start scanning'),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: isScanning ? null : _startScanning,
                  child: Text(isScanning ? 'Scanning...' : 'Start Scanning'),
                ),
              ),
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              if (scannedReservation != null)
                Padding(
                  padding:
                      const EdgeInsets.only(left: 100, right: 100, top: 40),
                  child: Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Ticket Name',
                              labelStyle:
                                  TextStyle(fontSize: 26, color: Colors.black),
                            ),
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            controller: TextEditingController(
                              text: scannedReservation!.eventName,
                            ),
                            readOnly: true,
                          ),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Event Day',
                              labelStyle:
                                  TextStyle(fontSize: 26, color: Colors.black),
                            ),
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            controller: TextEditingController(
                              text: DateFormat('dd/MM/yyyy')
                                  .format(scannedReservation!.eventDate),
                            ),
                            readOnly: true,
                          ),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Ticket Quantity',
                              labelStyle:
                                  TextStyle(fontSize: 26, color: Colors.black),
                            ),
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            controller: TextEditingController(
                                text: scannedReservation!.ticketQuantity
                                    .toString()),
                            readOnly: true,
                          ),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Selected Table Label',
                              labelStyle:
                                  TextStyle(fontSize: 26, color: Colors.black),
                            ),
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            controller: TextEditingController(
                                text: scannedReservation!.selectedTableLabel),
                            readOnly: true,
                          ),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Nickname User',
                              labelStyle:
                                  TextStyle(fontSize: 26, color: Colors.black),
                            ),
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            controller: TextEditingController(
                                text: scannedReservation!.nicknameUser),
                            readOnly: true,
                          ),
                          // TextField(
                          //   decoration: InputDecoration(
                          //     labelText: 'User Phone',
                          //     labelStyle:
                          //         TextStyle(fontSize: 26, color: Colors.black),
                          //   ),
                          //   style: TextStyle(fontSize: 20, color: Colors.black),
                          //   controller: TextEditingController(
                          //       text: scannedReservation!.userPhone),
                          //   readOnly: true,
                          // ),
                          // TextField(
                          //   decoration: InputDecoration(
                          //     labelText: 'Quantity Table',
                          //     labelStyle:
                          //         TextStyle(fontSize: 26, color: Colors.black),
                          //   ),
                          //   style: TextStyle(fontSize: 20, color: Colors.black),
                          //   controller: TextEditingController(
                          //       text: scannedReservation!.quantityTable
                          //           .toString()),
                          //   readOnly: true,
                          // ),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Check In',
                              labelStyle:
                                  TextStyle(fontSize: 26, color: Colors.black),
                            ),
                            style: TextStyle(fontSize: 20, color: Colors.red),
                            controller: TextEditingController(
                                text: scannedReservation!.checkIn.toString()),
                            readOnly: true,
                          ),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Shared Count',
                              labelStyle:
                                  TextStyle(fontSize: 26, color: Colors.black),
                            ),
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            controller: TextEditingController(
                                text:
                                    scannedReservation!.sharedCount.toString()),
                            readOnly: true,
                          ),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Total Prices',
                              labelStyle:
                                  TextStyle(fontSize: 26, color: Colors.black),
                            ),
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            controller: TextEditingController(
                                text: scannedReservation!.totalPayment
                                    .toString()),
                            readOnly: true,
                          ),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Payable',
                              labelStyle:
                                  TextStyle(fontSize: 26, color: Colors.black),
                            ),
                            style: TextStyle(fontSize: 20, color: Colors.green),
                            controller: TextEditingController(
                                text: scannedReservation!.payable.toString()),
                            readOnly: true,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Please select Table number & Round Table to customer!',
                            style: TextStyle(fontSize: 20, color: Colors.red),
                          ),
                          SizedBox(height: 10),
                          if (totalOfTableList.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Table No',
                                  labelStyle: TextStyle(
                                      fontSize: 26, color: Colors.black),
                                ),
                                value: selectedTableNo,
                                items: totalOfTableList
                                    .map<DropdownMenuItem<String>>((total) {
                                  return DropdownMenuItem<String>(
                                    value: total,
                                    child: Text('$selectedTableLabel $total',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black)),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedTableNo = newValue;
                                    print('$selectedTableLabel');
                                  });
                                },
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Round Table',
                                labelStyle: TextStyle(
                                    fontSize: 26, color: Colors.black),
                              ),
                              keyboardType: TextInputType.number,
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
                              controller: roundTableController,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _checkInCustomer,
                            child: Text(
                              'Check-In',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
