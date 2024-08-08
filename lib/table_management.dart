import 'package:back_office/component/drawer.dart';
import 'package:back_office/component/edit_table.dart';
import 'package:back_office/controller/table_controller.dart';
import 'package:back_office/model/login_model.dart';
import 'package:back_office/model/reserve_table_model.dart';
import 'package:back_office/services/table_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TableManagementScreen extends StatefulWidget {
  @override
  State<TableManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TableManagementScreen> {
  late ReserveTableHistoryController reservetablehistorycontroller =
      ReserveTableHistoryController(TableCatalogFirebaseService());
  bool isLoading = true;

  List<TableCatalog> tableCatalogs = [];
  List<ReserveTableHistory> reservetables = [];

  @override
  void initState() {
    super.initState();
    reservetablehistorycontroller =
        ReserveTableHistoryController(TableCatalogFirebaseService());
    _loadTableCatalog();
    _loadReserveTableHistory();
  }

  void _loadTableCatalog() async {
    try {
      final userId =
          Provider.of<MemberUserModel>(context, listen: false).memberUser!.id;
      // Fetch tables from Firebase
      tableCatalogs = await reservetablehistorycontroller.fetchTableCatalog();

      tableCatalogs =
          tableCatalogs.where((table) => table.partnerId == userId).toList();

      // Set the fetched tables into the provider
      Provider.of<ReserveTableProvider>(context, listen: false)
          .setTableCatalog(tableCatalogs);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading data: $e');
    }
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

  DateTime? _selectedTableDate;
  DateTimeRange? _selectedTableDateRange;
  DateTime? _selectedReserveDate;
  DateTimeRange? _selectedReserveDateRange;

  void _selectTableDateRange() async {
    DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2050),
      initialDateRange: _selectedTableDateRange ??
          DateTimeRange(
            start: DateTime.now(),
            end: DateTime.now()
                .add(const Duration(days: 7)), // Default to one week range
          ),
    );

    if (pickedRange != null && pickedRange != _selectedTableDateRange) {
      setState(() {
        _selectedTableDateRange = pickedRange;
        _selectedTableDate =
            null; // Clear the single date selection if range is updated
      });
      _filterTablesByDateRange(pickedRange);
    }
  }

  void _filterTablesByDateRange(DateTimeRange dateRange) {
    var filteredTables = tableCatalogs.where((table) {
      return table.onTheDay.isAfter(dateRange.start) &&
              table.onTheDay.isBefore(dateRange.end) ||
          table.onTheDay.isAtSameMomentAs(dateRange.start) ||
          table.onTheDay.isAtSameMomentAs(dateRange.end);
    }).toList();
    Provider.of<ReserveTableProvider>(context, listen: false)
        .setTableCatalog(filteredTables);
  }

  void _clearTableDateRange() {
    setState(() {
      _selectedTableDateRange = null;
    });
    _loadTableCatalog(); // Reload all tables or reset to your default view
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReserveTableProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text("Table Management"),
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/newtable');
                                },
                                child: const Text(
                                  "Add Table Information",
                                  style: TextStyle(
                                      fontSize: 22, color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.amber[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: _selectTableDateRange,
                                child: const Text(
                                  "Filter by Range",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (_selectedTableDateRange != null)
                                ElevatedButton(
                                  onPressed: _clearTableDateRange,
                                  child: const Text(
                                    "Clear Range",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors
                                        .red, // Optional: style the button with a red color to indicate a clear/reset action
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (_selectedTableDateRange != null)
                            Text(
                              "Selected Date: ${DateFormat('dd-MM-yyyy').format(
                                _selectedTableDateRange!.start,
                              )} to ${DateFormat('dd-MM-yyyy').format(_selectedTableDateRange!.end)}",
                              style: const TextStyle(fontSize: 20),
                            ),
                          const SizedBox(height: 10),
                          Expanded(
                            flex: 1,
                            child: GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // Adjust number of columns
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 5,
                                childAspectRatio: 3,
                              ),
                              itemCount: provider.allTables.length,
                              itemBuilder: (context, index) {
                                return _buildTableCard(
                                    context, provider.allTables[index]);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            // Expanded(
            //   flex: 2,
            //   child: Padding(
            //     padding: const EdgeInsets.all(10.0),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         SizedBox(height: 40),
            //         Row(
            //           children: [
            //             ElevatedButton(
            //               onPressed: _selectReserveDateRange,
            //               child: const Text(
            //                 "Filter by Range",
            //                 style: TextStyle(
            //                     fontSize: 20, fontWeight: FontWeight.bold),
            //               ),
            //             ),
            //             SizedBox(width: 10),
            //             if (_selectedReserveDateRange != null)
            //               ElevatedButton(
            //                 onPressed: _clearReserveDateRange,
            //                 child: const Text(
            //                   "Clear Range",
            //                   style: TextStyle(
            //                       fontSize: 20,
            //                       fontWeight: FontWeight.bold,
            //                       color: Colors.black),
            //                 ),
            //                 style: ElevatedButton.styleFrom(
            //                   primary: Colors.red,
            //                 ),
            //               ),
            //           ],
            //         ),
            //         const SizedBox(height: 20),
            //         if (_selectedReserveDateRange != null)
            //           Text(
            //             "Selected Date: ${DateFormat('dd-MM-yyyy').format(
            //               _selectedReserveDateRange!.start,
            //             )} to ${DateFormat('dd-MM-yyyy').format(_selectedReserveDateRange!.end)}",
            //             style: const TextStyle(fontSize: 16),
            //           ),
            //         const SizedBox(height: 10),
            //         Expanded(
            //           child: ListView.builder(
            //             itemCount: provider.allReserveTable.length,
            //             itemBuilder: (context, index) {
            //               final reservation = provider.allReserveTable[index];
            //               return _buildReservationCard(reservation);
            //             },
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTableCard(BuildContext context, TableCatalog catalog) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'On The Day: ${_formattedDate(catalog.onTheDay)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              'Close Date: ${catalog.closeDate ? "Yes" : "No"}',
              style: TextStyle(
                color: catalog.closeDate ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'Total Labels: ${catalog.tableLables.length}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.of(context).push(
                //       MaterialPageRoute(
                //         builder: (BuildContext context) => EditTablePage(catalog),
                //       ),
                //     );
                //   },
                //   child: const Text("Edit", style: TextStyle(fontSize: 16)),
                // ),
                ElevatedButton(
                  onPressed: () {
                    _showCloseConfirmationDialog(context, catalog);
                  },
                  child: Text(
                    catalog.closeDate ? "Reopen" : "Close",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

String _formattedDate(DateTime date) {
  return DateFormat('dd-MM-yyyy').format(date);
}

void _showCloseConfirmationDialog(BuildContext context, TableCatalog catalog) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirm"),
        content: Text(catalog.closeDate
            ? "Do you want to reopen the store?"
            : "Do you want to close the store?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text("Confirm"),
            onPressed: () {
              _updateCloseDate(context, catalog, !catalog.closeDate);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void _updateCloseDate(
    BuildContext context, TableCatalog catalog, bool newCloseDate) async {
  try {
    await FirebaseFirestore.instance
        .collection('table_catalog')
        .doc(catalog.id)
        .update({'closeDate': newCloseDate});

    // Optionally update the local state if needed
    catalog.closeDate = newCloseDate;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
        newCloseDate
            ? "Store closed successfully"
            : "Store reopened successfully",
        style: TextStyle(color: Colors.white),
      )),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
        "Failed to update the store status: $e",
        style: TextStyle(color: Colors.white),
      )),
    );
  }
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
                      color: reservation.payable ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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
