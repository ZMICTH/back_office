import 'package:back_office/component/drawer.dart';
import 'package:back_office/model/login_model.dart';
import 'package:back_office/model/reserve_table_model.dart';
import 'package:back_office/services/table_service.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddNewTablePage extends StatefulWidget {
  @override
  _AddNewTablePageState createState() => _AddNewTablePageState();
}

class _AddNewTablePageState extends State<AddNewTablePage> {
  late DateTime _availableDateStart;
  late DateTime _availableDateEnd;
  List<DateTime> _closeDates = [];
  late List<TableLabel> _tableLabels = [];

  @override
  void initState() {
    super.initState();
    _availableDateStart = DateTime.now();
    _availableDateEnd = DateTime.now().add(const Duration(days: 365));
    // Initialize _tableLabels from the provider if it has existing data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final memberUserModel =
          Provider.of<MemberUserModel>(context, listen: false);
      if (memberUserModel.memberUser != null) {
        setState(() {
          _tableLabels = memberUserModel.memberUser!.tableLabels.map((label) {
            return TableLabel(
              label: label['label'],
              numberofchairs: label['numberofchairs'],
              seats: label['seats'],
              tablePrices: label['tablePrices'],
              totaloftable: label['totaloftable'],
            );
          }).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('dd-MM-yyyy');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text("Create New Table Information"),
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
              // It takes 5/6 part of the screen
              flex: 5,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "1.Please select open day",
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: _pickDateRange,
                                      child: const Text(
                                        'Select Date Range',
                                        style: TextStyle(
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "Detail:",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Selected Start Date: ${dateFormat.format(_availableDateStart)}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Selected End Date: ${dateFormat.format(_availableDateEnd)}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      "2.Please select close day",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: _pickCloseDates,
                                      child: const Text(
                                        'Pick Close Dates',
                                        style: TextStyle(
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      children: _closeDates
                                          .map((date) => Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Chip(
                                                  label: Text(
                                                    DateFormat('dd-MM-yyyy')
                                                        .format(date),
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  onDeleted: () {
                                                    setState(() {
                                                      _closeDates.remove(date);
                                                    });
                                                  },
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      "3.Create Table Types",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    // ElevatedButton(
                                    //   onPressed: _addNewTableLabel,
                                    //   child: const Text(
                                    //     'Add Table Type',
                                    //     style: TextStyle(
                                    //       fontSize: 22,
                                    //     ),
                                    //   ),
                                    // ),
                                    const SizedBox(height: 10),
                                    Consumer<MemberUserModel>(
                                      builder:
                                          (context, memberUserModel, child) {
                                        final tableLabels = memberUserModel
                                            .memberUser!.tableLabels;

                                        return Wrap(
                                          children: tableLabels.map((label) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Chip(
                                                label: Text(
                                                  "${label['label']}: Seats - ${label['seats']}, Tables - ${label['totaloftable']}, Chairs - ${label['numberofchairs']}, Price - ${label['tablePrices'].toStringAsFixed(2)} THB",
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 30),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            final memberUserModel =
                                                Provider.of<MemberUserModel>(
                                                    context,
                                                    listen: false);
                                            final partnerId =
                                                memberUserModel.memberUser?.id;

                                            TableCatalogFirebaseService()
                                                .addTableData(
                                              partnerId!,
                                              _availableDateStart,
                                              _availableDateEnd,
                                              _closeDates,
                                              _tableLabels,
                                            )
                                                .then((_) {
                                              Navigator.of(context).pop();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Table information successfully saved.',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  backgroundColor:
                                                      Colors.green[600],
                                                ),
                                              );
                                              print('Data successfully saved.');
                                            }).catchError((error) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Error saving table information: $error',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  backgroundColor:
                                                      Colors.red[600],
                                                ),
                                              );
                                              print(
                                                  'Error saving data: $error');
                                            });
                                          },
                                          child: const Text(
                                            'Save Table Information',
                                            style: TextStyle(
                                              fontSize: 22,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 40,
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors
                                                .red, // Set the background color to red
                                          ),
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              fontSize: 22,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
    );
  }

  Future<void> _pickDateRange() async {
    // Pick the start date
    DateTime? selectedStartDate = await showDatePicker(
      context: context,
      initialDate: _availableDateStart,
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime(2030, 12, 31),
    );

    if (selectedStartDate != null) {
      // Once the start date is picked, pick the end date
      DateTime? selectedEndDate = await showDatePicker(
        context: context,
        initialDate: selectedStartDate.add(const Duration(
            days: 1)), // Default end date is one day after the start date
        firstDate: selectedStartDate,
        lastDate: DateTime(2030, 12, 31),
      );

      if (selectedEndDate != null) {
        setState(() {
          _availableDateStart = selectedStartDate;
          _availableDateEnd = selectedEndDate;
        });
      }
    }
  }

  Future<void> _pickCloseDates() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = now;
    final DateTime firstDate = DateTime(now.year, now.month - 3);
    final DateTime lastDate = DateTime(now.year + 3);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Close Dates"),
          content: Container(
            width: double.infinity,
            height: 400,
            child: dp.DayPicker.multi(
              selectedDates: _closeDates,
              onChanged: (List<DateTime> selected) {
                setState(() {
                  _closeDates = selected;
                  print(_closeDates);
                });
                Navigator.of(context).pop();
              },
              initiallyShowDate: initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
              datePickerLayoutSettings: const dp.DatePickerLayoutSettings(
                maxDayPickerRowCount: 6,
                showPrevMonthEnd: true,
                showNextMonthStart: true,
              ),
              datePickerStyles: dp.DatePickerRangeStyles(
                selectedPeriodLastDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedPeriodStartDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedPeriodMiddleDecoration: BoxDecoration(
                  color: Colors.blue[200],
                  shape: BoxShape.rectangle,
                ),
              ),
              eventDecorationBuilder: (date) {
                return dp.EventDecoration(
                  boxDecoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _addNewTableLabel() async {
    TextEditingController labelController = TextEditingController();
    TextEditingController numberOfChairsController = TextEditingController();
    TextEditingController seatsController = TextEditingController();
    TextEditingController tablePriceController = TextEditingController();
    TextEditingController totalOfTableController = TextEditingController();

    void updateNumberOfChairs() {
      final seats = int.tryParse(seatsController.text);
      final totalTables = int.tryParse(totalOfTableController.text);
      if (seats != null && totalTables != null) {
        final numberOfChairs = seats * totalTables;
        numberOfChairsController.text = numberOfChairs.toString();
        print("Updated Number of Chairs: $numberOfChairs");
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Table Type"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(hintText: "Label"),
                ),
                TextField(
                  controller: seatsController,
                  decoration: const InputDecoration(hintText: "Seats"),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    updateNumberOfChairs();
                  },
                ),
                TextField(
                  controller: totalOfTableController,
                  decoration: const InputDecoration(hintText: "Total of Table"),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    updateNumberOfChairs();
                  },
                ),
                TextField(
                  controller: numberOfChairsController,
                  decoration:
                      const InputDecoration(hintText: "Number of Chairs"),
                  keyboardType: TextInputType.number,
                  enabled: false, // Make this field read-only
                ),
                TextField(
                  controller: tablePriceController,
                  decoration: const InputDecoration(hintText: "Table Price"),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                print("Attempting to add new table type:");
                print("Label: ${labelController.text}");

                print("Seats: ${seatsController.text}");
                print("Total of Table: ${totalOfTableController.text}");
                print("Number of Chairs: ${numberOfChairsController.text}");
                print("Table Price: ${tablePriceController.text}");

                if (labelController.text.isNotEmpty &&
                    numberOfChairsController.text.isNotEmpty &&
                    seatsController.text.isNotEmpty &&
                    tablePriceController.text.isNotEmpty &&
                    totalOfTableController.text.isNotEmpty) {
                  setState(() {
                    _tableLabels.add(TableLabel(
                      label: labelController.text,
                      numberofchairs: int.parse(numberOfChairsController.text),
                      seats: int.parse(seatsController.text),
                      tablePrices: double.parse(tablePriceController.text),
                      totaloftable: int.parse(totalOfTableController.text),
                    ));
                    print("Table type added successfully.");
                  });
                  Navigator.of(context).pop();
                } else {
                  print("One or more fields are empty. No table type added.");
                }
              },
            ),
          ],
        );
      },
    );
  }
}
