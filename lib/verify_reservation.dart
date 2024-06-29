import 'package:back_office/component/drawer.dart';
import 'package:back_office/controller/table_controller.dart';
import 'package:back_office/model/login_model.dart';
import 'package:back_office/model/reserve_table_model.dart';
import 'package:back_office/services/table_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class VerifyReservationPage extends StatefulWidget {
  @override
  State<VerifyReservationPage> createState() => _VerifyReservationPageState();
}

class _VerifyReservationPageState extends State<VerifyReservationPage> {
  late ReserveTableHistoryController reservetablehistorycontroller =
      ReserveTableHistoryController(TableCatalogFirebaseService());
  bool isLoading = true;

  List<ReserveTableHistory> reservetables = [];

  DateTime? _selectedReserveDate;
  DateTimeRange? _selectedReserveDateRange;
  DateTime? _selectedTableDate;
  ReserveTableHistory? _selectedReservation;
  String? selectedTableNo;
  String? selectedTotalOfTable;

  final TextEditingController tableNoController = TextEditingController();
  final TextEditingController roundTableController = TextEditingController();

  @override
  void initState() {
    super.initState();
    reservetablehistorycontroller =
        ReserveTableHistoryController(TableCatalogFirebaseService());
    _loadReserveTableHistory();
  }

  @override
  void dispose() {
    tableNoController.dispose();
    roundTableController.dispose();
    super.dispose();
  }

  void _loadReserveTableHistory() async {
    try {
      final userId =
          Provider.of<MemberUserModel>(context, listen: false).memberUser!.id;
      // Fetch tables from Firebase
      reservetables =
          await reservetablehistorycontroller.fetchReserveTableHistory();

      reservetables = reservetables
          .where((reserve) => reserve.partnerId == userId)
          .toList();
      // Set the fetched tables into the provider
      Provider.of<ReserveTableProvider>(context, listen: false)
          .setReserveTable(reservetables);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading data: $e');
    }
  }

  void _selectReserveDateRange() async {
    DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2050),
      initialDateRange: _selectedReserveDateRange ??
          DateTimeRange(
            start: DateTime.now(),
            end: DateTime.now()
                .add(const Duration(days: 7)), // Default to one week range
          ),
    );

    if (pickedRange != null && pickedRange != _selectedReserveDateRange) {
      setState(() {
        _selectedReserveDateRange = pickedRange;
        _selectedTableDate =
            null; // Clear the single date selection if range is updated
      });
      _filterReservesByDateRange(pickedRange);
    }
  }

  void _filterReservesByDateRange(DateTimeRange dateRange) {
    var filteredReserves = reservetables.where((reserve) {
      return reserve.formattedSelectedDay.isAfter(dateRange.start) &&
              reserve.formattedSelectedDay.isBefore(dateRange.end) ||
          reserve.formattedSelectedDay.isAtSameMomentAs(dateRange.start) ||
          reserve.formattedSelectedDay.isAtSameMomentAs(dateRange.end);
    }).toList();
    Provider.of<ReserveTableProvider>(context, listen: false)
        .setReserveTable(filteredReserves);
  }

  void _clearReserveDateRange() {
    setState(() {
      _selectedReserveDateRange = null;
    });
    _loadReserveTableHistory(); // Reload all tables or reset to your default view
  }

  Future<void> _checkInCustomer() async {
    if (_selectedReservation != null) {
      if (await _validateCheckIn()) {
        final userId = _selectedReservation!.userId;
        final selectedTableLabel = _selectedReservation!.selectedTableLabel;
        final tableLabelWithTotal = '$selectedTableLabel $selectedTableNo';
        final partnerId =
            Provider.of<MemberUserModel>(context, listen: false).memberUser!.id;

        // Update the checkIn status in the provider
        Provider.of<ReserveTableProvider>(context, listen: false)
            .updateCheckInStatus(_selectedReservation!.id, true);

        // Update the user's useService in the Firestore collection
        await FirebaseFirestore.instance.collection('User').doc(userId).update({
          'useService': FieldValue.arrayUnion([
            {
              'partnerId': partnerId,
              'date': _selectedReservation!.formattedSelectedDay,
              'roundtable': roundTableController.text,
              'tableNo': tableLabelWithTotal,
            }
          ]),
        });

        // Update the reservation_table collection with tableNo and roundtable
        await FirebaseFirestore.instance
            .collection('reservation_table')
            .doc(_selectedReservation!.id)
            .set({
          'checkIn': true,
          'tableNo': tableLabelWithTotal,
          'roundtable': roundTableController.text,
          'checkOut': false,
          'getTableTime': DateTime.now(),
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
  }

  Future<bool> _validateCheckIn() async {
    final provider = Provider.of<ReserveTableProvider>(context, listen: false);
    final selectedDate = _selectedReservation!.formattedSelectedDay;

    // Check for roundTable duplication
    final roundTableExists = provider.allReserveTable.any((reservation) =>
        reservation.formattedSelectedDay
            .toLocal()
            .isAtSameMomentAs(selectedDate.toLocal()) &&
        reservation.tableNo == selectedTableNo &&
        reservation.roundTable == roundTableController.text);

    if (roundTableExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'This round table already exists for the selected table number on this date.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Check for checkIn status
    final tableAlreadyCheckedIn = provider.allReserveTable.any((reservation) =>
        reservation.formattedSelectedDay
            .toLocal()
            .isAtSameMomentAs(selectedDate.toLocal()) &&
        reservation.tableNo == selectedTableNo &&
        reservation.checkIn);

    if (tableAlreadyCheckedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'This table has already been checked in for the selected date.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReserveTableProvider>(context);
    final memberUserModel = Provider.of<MemberUserModel>(context);
    final tableLabels = memberUserModel.memberUser?.tableLabels ?? [];

    final matchingTable = tableLabels.firstWhere(
        (table) => table['label'] == _selectedReservation?.selectedTableLabel,
        orElse: () => <String, dynamic>{});

    final totalOfTableList = matchingTable.isNotEmpty
        ? List.generate(
            matchingTable['totaloftable'], (index) => (index + 1).toString())
        : [];

    // Filter reservations for today
    final today = DateTime.now();
    final todayReservations = provider.allReserveTable.where((reservation) {
      return reservation.formattedSelectedDay.year == today.year &&
          reservation.formattedSelectedDay.month == today.month &&
          reservation.formattedSelectedDay.day == today.day;
    }).toList();

    // Sort the reservations by formattedSelectedDay
    var sortedReservations = provider.allReserveTable;
    sortedReservations.sort(
        (b, a) => a.formattedSelectedDay.compareTo(b.formattedSelectedDay));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text("Verify Booking"),
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
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/qrtable');
                          },
                          child: Text(
                            'Go to QR Table',
                            style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                            backgroundColor: Colors.blueGrey[600],
                          ),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/qrticket');
                          },
                          child: Text(
                            'Go to QR Ticket',
                            style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                            backgroundColor: Colors.blueGrey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 40),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: _selectReserveDateRange,
                                    child: const Text(
                                      "Filter by Range",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  if (_selectedReserveDateRange != null)
                                    ElevatedButton(
                                      onPressed: _clearReserveDateRange,
                                      child: const Text(
                                        "Clear Range",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.red,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              if (_selectedReserveDateRange != null)
                                Text(
                                  "Selected Date: ${DateFormat('dd-MM-yyyy').format(
                                    _selectedReserveDateRange!.start,
                                  )} to ${DateFormat('dd-MM-yyyy').format(_selectedReserveDateRange!.end)}",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: todayReservations.length,
                      itemBuilder: (context, index) {
                        final reservation = todayReservations[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedReservation = reservation;
                            });
                          },
                          child: _buildReservationCard(reservation),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            VerticalDivider(),
            Expanded(
              flex: 1,
              child: _selectedReservation != null
                  ? _buildReservationDetails(_selectedReservation!)
                  : Center(child: Text("Select a reservation to view details")),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationCard(ReserveTableHistory reservation) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${reservation.nicknameUser} (${reservation.userPhone})",
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Check Status: ${reservation.checkIn ? "Yes" : "No"}',
                  style: TextStyle(
                    fontSize: 16,
                    color: reservation.checkIn ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  "Reserved on ${DateFormat('yyyy-MM-dd').format(reservation.formattedSelectedDay)}",
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
                "Table type : ${reservation.selectedTableLabel} and booking ${reservation.selectedSeats} seats "),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  children: [
                    Text(
                        "Total amount: ${reservation.totalPrices.toStringAsFixed(2)} THB"),
                    Text(
                      'Payment Status: ${reservation.payable ? "Yes" : "No"}',
                      style: TextStyle(
                          color:
                              reservation.payable ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationDetails(ReserveTableHistory reservation) {
    final memberUserModel = Provider.of<MemberUserModel>(context);
    final tableLabels = memberUserModel.memberUser?.tableLabels ?? [];
    final matchingTable = tableLabels.firstWhere(
        (table) => table['label'] == reservation.selectedTableLabel,
        orElse: () => <String, dynamic>{});
    final totalOfTableList = matchingTable.isNotEmpty
        ? List.generate(
            matchingTable['totaloftable'], (index) => (index + 1).toString())
        : [];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text("Reservation Details",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
                "User: ${reservation.nicknameUser} (${reservation.userPhone})"),
            const SizedBox(height: 10),
            Text(
                "Date: ${DateFormat('yyyy-MM-dd').format(reservation.formattedSelectedDay)}"),
            const SizedBox(height: 10),
            Text("Table: ${reservation.selectedTableLabel}"),
            const SizedBox(height: 10),
            Text("Seats: ${reservation.selectedSeats}"),
            const SizedBox(height: 10),
            Text(
                "Total Amount: ${reservation.totalPrices.toStringAsFixed(2)} THB"),
            const SizedBox(height: 10),
            Text(
              "Payment Status: ${reservation.payable ? "Yes" : "No"}",
              style: TextStyle(
                color: reservation.payable ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text("Shared Count: ${reservation.sharedCount}"),
            const SizedBox(height: 10),
            Text(
              'Please select Table number & Round Table to customer!',
              style: TextStyle(fontSize: 20, color: Colors.red),
            ),
            if (totalOfTableList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Table No',
                    labelStyle: TextStyle(fontSize: 22, color: Colors.black),
                  ),
                  alignment: AlignmentDirectional.center,
                  value: selectedTableNo,
                  items:
                      totalOfTableList.map<DropdownMenuItem<String>>((total) {
                    return DropdownMenuItem<String>(
                      alignment: AlignmentDirectional.center,
                      value: total,
                      child: Text('${reservation.selectedTableLabel} $total',
                          style: TextStyle(fontSize: 20, color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTableNo = newValue;
                    });
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Round Table',
                  labelStyle: TextStyle(fontSize: 22, color: Colors.black),
                ),
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 22, color: Colors.black),
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
    );
  }
}
