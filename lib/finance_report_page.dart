import 'dart:io';

import 'package:back_office/component/drawer.dart';
import 'package:back_office/model/bill_order_model.dart';
import 'package:back_office/model/reserve_table_model.dart';
import 'package:back_office/model/reserve_ticket_model.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

class FinancialReportPage extends StatefulWidget {
  @override
  State<FinancialReportPage> createState() => _FinancialReportPageState();
}

class _FinancialReportPageState extends State<FinancialReportPage> {
  List<Map<String, dynamic>> _currentReportData = [];
  String _currentReportLabel = '';
  DateTimeRange? _selectedDateRange;

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _selectedDateRange ??
          DateTimeRange(start: DateTime.now(), end: DateTime.now()),
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _filterReportData(); // Filter data based on the selected date range
      });
    }
  }

  void _clearDateRange() {
    setState(() {
      _selectedDateRange = null;
      _filterReportData();
    });
  }

  void _filterReportData() {
    if (_selectedDateRange != null && _currentReportData.isNotEmpty) {
      DateTime startDate = _selectedDateRange!.start;
      DateTime endDate =
          _selectedDateRange!.end.add(Duration(days: 1)); // include end date
      _currentReportData = _currentReportData.where((data) {
        DateTime billingTime = DateTime.parse(data['Date']);
        return billingTime.isAfter(startDate) && billingTime.isBefore(endDate);
      }).toList();
    }
  }

  Widget _buildSummary() {
    int totalRecords = _currentReportData.length;
    double totalSales = _currentReportData.fold(0, (sum, item) {
      return sum + (item['Total Price'] ?? 0);
    });

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Records: $totalRecords',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Total Sales: ${totalSales.toStringAsFixed(2)} THB',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildReportButton(BuildContext context, String label,
      List<Map<String, dynamic>> reportData) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _currentReportLabel = label;
            _currentReportData = reportData;
            _filterReportData(); // Filter data when selecting a report
          });
        },
        child: Text(
          label,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: _currentReportData.first.keys
              .map((key) => DataColumn(label: Text(key)))
              .toList(),
          rows: _currentReportData
              .map((data) => DataRow(
                  cells: data.values
                      .map((value) => DataCell(Text(value.toString())))
                      .toList()))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () =>
            _createAndSaveReport(_currentReportLabel, _currentReportData),
        child: Text(
          'Download $_currentReportLabel',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Future<void> _createAndSaveReport(
      String label, List<Map<String, dynamic>> reportData) async {
    var excel = Excel.createExcel();
    Sheet sheet = excel[label];

    // Append the summary at the top of the sheet
    int totalRecords = reportData.length;
    double totalSales = reportData.fold(0, (sum, item) {
      return sum + (item['Total Price'] ?? 0);
    });

    final DateFormat formatter = DateFormat('dd/MM/yyyy');

    sheet.appendRow(['Summary']);
    if (_selectedDateRange != null) {
      String formattedStartDate = formatter.format(_selectedDateRange!.start);
      String formattedEndDate = formatter.format(_selectedDateRange!.end);
      sheet.appendRow(
          ['Date Range', '$formattedStartDate to $formattedEndDate']);
    }
    sheet.appendRow(['Total Records', totalRecords]);
    sheet.appendRow(['Total Sales', totalSales.toStringAsFixed(2)]);
    sheet.appendRow([]); // Empty row for spacing

    // Append the report data
    sheet.appendRow(reportData.first.keys.toList());
    for (var row in reportData) {
      sheet.appendRow(row.values.toList());
    }

    var fileBytes = excel.save();
    var directory = await getApplicationDocumentsDirectory();
    File file = File(join(directory.path, '$label.xlsx'))
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);

    print('Report saved to ${file.path}');

    // Share the file
    Share.shareFiles([file.path], text: 'Here is the $label report');
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: const Text("Download Report"),
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
      body: Consumer<BillOrderProvider>(
        builder: (context, billOrderProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _buildReportButton(context, 'Sale Report',
                        billOrderProvider.foodSalesData),
                    Consumer<ReserveTableProvider>(
                      builder: (context, reserveTableProvider, child) {
                        return _buildReportButton(
                            context,
                            'Reserve Table Report',
                            reserveTableProvider.reserveTableData);
                      },
                    ),
                    Consumer<ReservationTicketProvider>(
                      builder: (context, reservationTicketProvider, child) {
                        return _buildReportButton(
                            context,
                            'Reserve Ticket Report',
                            reservationTicketProvider.reservationTicketData);
                      },
                    ),
                  ],
                ),
                // Add date filter buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectDateRange(context),
                      child: Text(
                        'Select Date Range',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _clearDateRange,
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                if (_selectedDateRange != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Selected Date Range: ${formatter.format(_selectedDateRange!.start)} - ${formatter.format(_selectedDateRange!.end)}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                SizedBox(height: 15),
                if (_currentReportData.isNotEmpty)
                  _buildSummary(), // Add summary
                if (_currentReportData.isNotEmpty) _buildDataTable(),
                if (_currentReportData.isNotEmpty) _buildDownloadButton(),
              ],
            ),
          );
        },
      ),
    );
  }
}
