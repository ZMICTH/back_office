import 'package:back_office/component/drawer.dart';
import 'package:back_office/controller/reserve_ticket_controller.dart';
import 'package:back_office/controller/table_controller.dart';
import 'package:back_office/model/login_model.dart';
import 'package:back_office/model/reserve_table_model.dart';
import 'package:back_office/model/reserve_ticket_model.dart';
import 'package:back_office/services/reserve_ticket_service.dart';
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
  late TicketConcertController ticketconcertcontroller =
      TicketConcertController(TicketConcertFirebaseService());
  bool isLoading = true;

  List<ReserveTableHistory> reservetables = [];
  List<String> availableTables = [];
  List<TicketConcertModel> ticketCats = [];

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
    ticketconcertcontroller =
        TicketConcertController(TicketConcertFirebaseService());

    _loadAllTickets();
    _checkTodayEvent();
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
      // Update reserved combinations in the provider
      Provider.of<ReserveTableProvider>(context, listen: false)
          .setReserveTable(reservetables);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading data: $e');
    }
  }

  Future<void> _loadAllTickets() async {
    try {
      final userId =
          Provider.of<MemberUserModel>(context, listen: false).memberUser!.id;
      var tickets = await ticketconcertcontroller.fetchTicketConcertModel();
      tickets = tickets.where((order) => order.partnerId == userId).toList();
      Provider.of<ReservationTicketProvider>(context, listen: false)
          .setTicketCatalog(tickets);
    } catch (e) {
      print('Error fetching ConcertTickets: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _checkTodayEvent() async {
    final providerTicket =
        Provider.of<ReservationTicketProvider>(context, listen: false);
    final today = DateTime.now();
    final concertReservations = providerTicket.AllTickets.where((reservation) {
      return reservation.eventDate.year == today.year &&
          reservation.eventDate.month == today.month &&
          reservation.eventDate.day == today.day;
    }).toList();

    if (concertReservations.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTodayEventDialog(concertReservations);
      });
    }
  }

  void _showTodayEventDialog(List<TicketConcertModel> concertReservations) {
    showDialog(
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Text(
            'Today\'s ${concertReservations.first.eventName} Event',
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.bold, color: Colors.red),
          ),
          content: Text(
            'Would you like to verify the tickets?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/verifyticket');
              },
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                'Go Back',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _selectReserveDateRange() async {
  //   DateTimeRange? pickedRange = await showDateRangePicker(
  //     context: context,
  //     firstDate: DateTime(2023),
  //     lastDate: DateTime(2050),
  //     initialDateRange: _selectedReserveDateRange ??
  //         DateTimeRange(
  //           start: DateTime.now(),
  //           end: DateTime.now()
  //               .add(const Duration(days: 7)), // Default to one week range
  //         ),
  //   );

  //   if (pickedRange != null && pickedRange != _selectedReserveDateRange) {
  //     setState(() {
  //       _selectedReserveDateRange = pickedRange;
  //       _selectedTableDate =
  //           null; // Clear the single date selection if range is updated
  //     });
  //     _filterReservesByDateRange(pickedRange);
  //   }
  // }

  // void _filterReservesByDateRange(DateTimeRange dateRange) {
  //   var filteredReserves = reservetables.where((reserve) {
  //     return reserve.formattedSelectedDay.isAfter(dateRange.start) &&
  //             reserve.formattedSelectedDay.isBefore(dateRange.end) ||
  //         reserve.formattedSelectedDay.isAtSameMomentAs(dateRange.start) ||
  //         reserve.formattedSelectedDay.isAtSameMomentAs(dateRange.end);
  //   }).toList();
  //   Provider.of<ReserveTableProvider>(context, listen: false)
  //       .setReserveTable(filteredReserves);
  // }

  // void _clearReserveDateRange() {
  //   setState(() {
  //     _selectedReserveDateRange = null;
  //   });
  //   _loadReserveTableHistory(); // Reload all tables or reset to your default view
  // }

  Future<void> _fetchAvailableTables() async {
    final provider = Provider.of<ReserveTableProvider>(context, listen: false);
    final memberUserModel =
        Provider.of<MemberUserModel>(context, listen: false);

    if (_selectedReservation != null) {
      final DateTime selectedDate = _selectedReservation!.formattedSelectedDay;
      final String selectedLabel = _selectedReservation!.selectedTableLabel;
      final userId = memberUserModel.memberUser!.id;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('reservation_table')
          .where('formattedSelectedDay',
              isEqualTo: Timestamp.fromDate(selectedDate))
          .where('selectedTableLabel', isEqualTo: selectedLabel)
          .where('checkIn', isEqualTo: true)
          .where('checkOut', isEqualTo: false)
          .get();

      List<String> checkedInTables = snapshot.docs
          .map((doc) =>
              (doc.data() as Map<String, dynamic>)['tableNo'] as String)
          .toList();

      final List<Map<String, dynamic>> tableLabels =
          memberUserModel.memberUser?.tableLabels ?? [];
      final Map<String, dynamic> matchingTable = tableLabels.firstWhere(
          (table) => table['label'] == selectedLabel,
          orElse: () => <String, dynamic>{});

      final List<String> totalOfTableList = matchingTable.isNotEmpty
          ? List.generate(
              matchingTable['totaloftable'], (index) => (index + 1).toString())
          : [];

      availableTables = totalOfTableList
          .where((table) => !checkedInTables.contains('$selectedLabel $table'))
          .toList();

      setState(() {});
    }
  }

  Future<void> _checkInCustomer() async {
    if (_selectedReservation != null) {
      if (await _validateCheckIn()) {
        final userId = _selectedReservation!.userId;

        final tableLabelWithTotal = '$selectedTableNo';
        final partnerId =
            Provider.of<MemberUserModel>(context, listen: false).memberUser!.id;

        // Update the checkIn status in the provider
        Provider.of<ReserveTableProvider>(context, listen: false)
            .updateCheckInStatus(_selectedReservation!.id, true);

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
            content: Text(
              'Customer checked in successfully!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        print("Customer checked in successfully: $tableLabelWithTotal");
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
        reservation.roundtable == roundTableController.text);

    if (roundTableExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'This round table already exists for the selected table number on this date.',
            style: TextStyle(color: Colors.white),
          ),
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
            'This table has already been checked in for the selected date.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _confirmOutOfTimeCheckIn() async {
    final provider = Provider.of<ReserveTableProvider>(context, listen: false);

    if (_selectedReservation != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Confirm Out of Time Check-In",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            content: Text(
                "Are you sure you want to mark this reservation as out of time check-in?"),
            actions: <Widget>[
              TextButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                child: Text(
                  "Confirm",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _outOfTimeCheckInCustomer(); // Call the out of time check-in function
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No reservation selected.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      print("Out of Time Check-In failed: No reservation selected.");
    }
  }

  Future<void> _outOfTimeCheckInCustomer() async {
    final provider = Provider.of<ReserveTableProvider>(context, listen: false);

    if (_selectedReservation != null) {
      try {
        // Update the reservation_table collection with tableNo and roundtable
        await FirebaseFirestore.instance
            .collection('reservation_table')
            .doc(_selectedReservation!.id)
            .set({
          'checkIn': false,
          'tableNo': null,
          'roundtable': null,
          'checkOut': false,
          'getTableTime': DateTime.now(),
          'outOfTimeCheckIn': true,
        }, SetOptions(merge: true));

        // Reset selectedTableNo after processing
        provider.setSelectedTableNo(null);

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Out of Time Check-In processed successfully!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        print("Out of Time Check-In processed successfully.");
      } catch (e) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error processing Out of Time Check-In: $e',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        print("Error processing Out of Time Check-In: $e");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No reservation selected.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      print("Out of Time Check-In failed: No reservation selected.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReserveTableProvider>(context);
    final today = DateTime.now();
    final todayReservations = provider.allReserveTable.where((reservation) {
      return reservation.formattedSelectedDay.year == today.year &&
          reservation.formattedSelectedDay.month == today.month &&
          reservation.formattedSelectedDay.day == today.day;
    }).toList();

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
                            'Scan QR Table',
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
                        // SizedBox(width: 20),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     Navigator.pushNamed(context, '/qrticket');
                        //   },
                        //   child: Text(
                        //     'Go to QR Ticket',
                        //     style: TextStyle(
                        //         fontSize: 24,
                        //         color: Colors.white,
                        //         fontWeight: FontWeight.bold),
                        //   ),
                        //   style: ElevatedButton.styleFrom(
                        //     padding: EdgeInsets.symmetric(
                        //         horizontal: 30, vertical: 10),
                        //     backgroundColor: Colors.blueGrey[600],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       flex: 2,
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(10.0),
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             SizedBox(height: 40),
                  //             Row(
                  //               children: [
                  //                 ElevatedButton(
                  //                   onPressed: _selectReserveDateRange,
                  //                   child: const Text(
                  //                     "Filter by Range",
                  //                     style: TextStyle(
                  //                         fontSize: 20,
                  //                         fontWeight: FontWeight.bold),
                  //                   ),
                  //                 ),
                  //                 SizedBox(width: 10),
                  //                 if (_selectedReserveDateRange != null)
                  //                   ElevatedButton(
                  //                     onPressed: _clearReserveDateRange,
                  //                     child: const Text(
                  //                       "Clear Range",
                  //                       style: TextStyle(
                  //                           fontSize: 20,
                  //                           fontWeight: FontWeight.bold,
                  //                           color: Colors.black),
                  //                     ),
                  //                     style: ElevatedButton.styleFrom(
                  //                       primary: Colors.red,
                  //                     ),
                  //                   ),
                  //               ],
                  //             ),
                  //             const SizedBox(height: 20),
                  //             if (_selectedReserveDateRange != null)
                  //               Text(
                  //                 "Selected Date: ${DateFormat('dd-MM-yyyy').format(
                  //                   _selectedReserveDateRange!.start,
                  //                 )} to ${DateFormat('dd-MM-yyyy').format(_selectedReserveDateRange!.end)}",
                  //                 style: const TextStyle(fontSize: 16),
                  //               ),
                  //             const SizedBox(height: 10),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: todayReservations.length,
                      itemBuilder: (context, index) {
                        final reservation = todayReservations[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedReservation = reservation;
                              _fetchAvailableTables();
                              // Fetch available tables when a reservation is selected
                            });
                          },
                          child: ReservationCard(reservation),
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

  Widget _buildReservationDetails(ReserveTableHistory reservation) {
    final numberFormat = NumberFormat("#,##0", "en_US");
    return Consumer2<ReserveTableProvider, MemberUserModel>(
      builder: (context, provider, memberUserModel, child) {
        final tableLabels = memberUserModel.memberUser?.tableLabels ?? [];
        final matchingTable = tableLabels.firstWhere(
            (table) => table['label'] == reservation.selectedTableLabel,
            orElse: () => <String, dynamic>{});
        final totalOfTableList = matchingTable.isNotEmpty
            ? provider.getAvailableTables(
                memberUserModel, reservation.selectedTableLabel)
            : [];

        // Get the round table availability
        final roundTableAvailability = selectedTableNo != null
            ? provider.getRoundTableAvailability(
                selectedTableNo!, reservation.formattedSelectedDay)
            : {};

        print("Matching table: $matchingTable");
        print("Total of table list: $totalOfTableList");
        print("Round table availability: $roundTableAvailability");

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  "Reservation Details",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
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
                    "Total Amount: ${numberFormat.format(reservation.totalPrices)} THB"),
                const SizedBox(height: 10),
                Text(
                  "Payment Status: ${reservation.payable ? "Paid" : "Not Paid"}",
                  style: TextStyle(
                    color: reservation.payable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text("Shared Count: ${reservation.sharedWith!.length}"),
                const SizedBox(height: 10),
                Text(
                  "Check-In Status: ${reservation.checkIn ? "Checked In" : "Not Checked In"}",
                  style: TextStyle(
                    color: reservation.checkIn ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                if (reservation.checkIn) ...[
                  Text("Table No: ${reservation.tableNo ?? "N/A"}"),
                  const SizedBox(height: 10),
                  Text("Round Table: ${reservation.roundtable ?? "N/A"}"),
                ] else if (reservation.outOfTimeCheckIn == true) ...[
                  Text(
                    "Out of Time Check-In",
                    style: TextStyle(fontSize: 20, color: Colors.red),
                  ),
                ] else ...[
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
                          labelStyle:
                              TextStyle(fontSize: 22, color: Colors.black),
                        ),
                        alignment: AlignmentDirectional.center,
                        value: selectedTableNo,
                        items: totalOfTableList
                            .map<DropdownMenuItem<String>>((total) {
                          return DropdownMenuItem<String>(
                            alignment: AlignmentDirectional.center,
                            value: total,
                            child: Text('${total}',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedTableNo = newValue;
                            print("Selected table number: $selectedTableNo");

                            // Update round table availability when table number is changed
                            final roundTableAvailability =
                                provider.getRoundTableAvailability(
                                    selectedTableNo!,
                                    reservation.formattedSelectedDay);
                            print(
                                "Round table availability: $roundTableAvailability");
                          });
                        },
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Round Table',
                        labelStyle:
                            TextStyle(fontSize: 22, color: Colors.black),
                      ),
                      alignment: AlignmentDirectional.center,
                      value: roundTableAvailability.entries
                          .firstWhere(
                            (entry) => entry.value,
                            orElse: () =>
                                const MapEntry<String, bool>('1', true),
                          )
                          .key,
                      items: roundTableAvailability.entries
                          .map<DropdownMenuItem<String>>((entry) {
                        return DropdownMenuItem<String>(
                          alignment: AlignmentDirectional.center,
                          value: entry.key,
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 20,
                              color: entry.value ? Colors.black : Colors.grey,
                            ),
                          ),
                          enabled: entry.value,
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          roundTableController.text = newValue ?? '';
                          print(
                              "Selected round table: ${roundTableController.text}");
                        });
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _checkInCustomer,
                    child: Text(
                      'Check-In',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _confirmOutOfTimeCheckIn,
                    child: Text(
                      'Out of Time Check-In',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.orange, // Button color
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class ReservationCard extends StatelessWidget {
  final ReserveTableHistory reservation;

  ReservationCard(this.reservation);

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat("#,##0", "en_US");
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
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Check Status: ${reservation.checkIn ? "Checked In" : "Not Checked In"}',
                  style: TextStyle(
                    fontSize: 18,
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
                        "Total amount: ${numberFormat.format(reservation.totalPrices)} THB"),
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
}
