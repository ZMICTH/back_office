import 'package:back_office/component/drawer.dart';
import 'package:back_office/model/reserve_table_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditTablePage extends StatefulWidget {
  final TableCatalog catalog;

  EditTablePage(this.catalog);

  @override
  _EditTablePageState createState() => _EditTablePageState();
}

class _EditTablePageState extends State<EditTablePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _totalOfTableController = TextEditingController();
  final TextEditingController _tablePricesController = TextEditingController();
  final TextEditingController _numberofchairsController =
      TextEditingController();

  DateTime? _selectedDate;
  bool _isCloseDate = false;

  @override
  void initState() {
    super.initState();
    _isCloseDate = widget.catalog.closeDate;
    _selectedDate = widget.catalog.onTheDay;
    if (widget.catalog.tableLables.isNotEmpty) {
      _labelController.text = widget.catalog.tableLables.first.label;
      _seatsController.text = widget.catalog.tableLables.first.seats.toString();
      _totalOfTableController.text =
          widget.catalog.tableLables.first.totaloftable.toString();
      _tablePricesController.text =
          widget.catalog.tableLables.first.tablePrices.toStringAsFixed(2);
      _numberofchairsController.text =
          widget.catalog.tableLables.first.numberofchairs.toString();
    }

    _seatsController.addListener(_updateNumberOfChairs);
    _totalOfTableController.addListener(_updateNumberOfChairs);
  }

  void _updateNumberOfChairs() {
    if (_seatsController.text.isNotEmpty &&
        _totalOfTableController.text.isNotEmpty) {
      final int seats = int.tryParse(_seatsController.text) ?? 0;
      final int totalTables = int.tryParse(_totalOfTableController.text) ?? 0;
      _numberofchairsController.text = (seats * totalTables).toString();
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _seatsController.dispose();
    _totalOfTableController.dispose();
    _tablePricesController.dispose();
    _numberofchairsController.dispose();
    _seatsController.removeListener(_updateNumberOfChairs);
    _totalOfTableController.removeListener(_updateNumberOfChairs);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Ticket"),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
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
            flex: 5,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                        'Available Date: ${_selectedDate != null ? DateFormat('dd-MM-yyyy').format(_selectedDate!) : 'Not set'}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2050),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                          print(_selectedDate);
                        });
                      }
                    },
                  ),
                  SwitchListTile(
                    title: Text('Is Close Date'),
                    value: _isCloseDate,
                    onChanged: (bool value) {
                      setState(() {
                        _isCloseDate = value;
                        print(_isCloseDate);
                      });
                    },
                  ),
                  TextFormField(
                    controller: _labelController,
                    decoration: InputDecoration(labelText: 'Table Label'),
                  ),
                  TextFormField(
                    controller: _seatsController,
                    decoration: InputDecoration(labelText: 'Seats'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _totalOfTableController,
                    decoration: InputDecoration(labelText: 'Total of Tables'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _numberofchairsController,
                    decoration: InputDecoration(labelText: 'Number of Chairs'),
                  ),
                  TextFormField(
                    controller: _tablePricesController,
                    decoration: InputDecoration(labelText: 'Table Prices'),
                    keyboardType: TextInputType.numberWithOptions(
                        decimal: true), // Allow decimal input
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          primary:
                              Colors.red, // Set the background color to red
                        ),
                        child: Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: _saveChanges,
                        child: Text('Save Changes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    DateTime? onTheDay = _selectedDate;
    String label = _labelController.text;
    bool closeDate = _isCloseDate;
    int? seats = int.tryParse(_seatsController.text);
    int? totalOfTable = int.tryParse(_totalOfTableController.text);
    int? numberofchairs = int.tryParse(_numberofchairsController.text);
    double? tablePrices = double.tryParse(_tablePricesController.text);

    if (seats != null &&
        totalOfTable != null &&
        tablePrices != null &&
        onTheDay != null) {
      // Create a map of data to update
      Map<String, dynamic> updateData = {
        'onTheDay': Timestamp.fromDate(onTheDay),
        'closeDate': closeDate,
        'tableLables': [
          {
            'label': label,
            'seats': seats,
            'totaloftable': totalOfTable,
            'numberofchairs': numberofchairs,
            'tablePrices': tablePrices,
          }
        ]
      };

      // Update the document in Firestore
      _firestore
          .collection('table_catalog')
          .doc(widget.catalog.id)
          .update(updateData)
          .then((_) {
        print('Update successful');
        Navigator.of(context)
            .pop(); // Optionally pop back or show a success message
      }).catchError((error) {
        print('Error updating document: $error');
        // Optionally show error message to user
      });
    } else {
      print('Validation failed');
      // Optionally show validation error message to user
    }
  }
}
