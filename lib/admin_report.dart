import 'dart:io';

import 'package:back_office/model/bill_order_model.dart';
import 'package:back_office/model/reserve_ticket_model.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:back_office/model/reserve_table_model.dart';

class AdminReportPage extends StatefulWidget {
  @override
  State<AdminReportPage> createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  bool isLoading = true;

  List<Map<String, dynamic>> _currentReportData = [];
  String _currentReportLabel = '';

  @override
  Widget build(BuildContext context) {
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
      ),
      body: Consumer<BillOrderProvider>(
        builder: (context, billOrderProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _buildReportButton(
                      context, 'Sale Report', billOrderProvider.foodSalesData),
                  Consumer<ReserveTableProvider>(
                    builder: (context, reserveTableProvider, child) {
                      return _buildReportButton(context, 'Reserve Table Report',
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
              if (_currentReportData.isNotEmpty) _buildDataTable(),
              if (_currentReportData.isNotEmpty) _buildDownloadButton(),
            ],
          );
        },
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
}
