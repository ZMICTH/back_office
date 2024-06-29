import 'dart:io';

import 'package:back_office/component/drawer.dart';

import 'package:back_office/model/login_model.dart';
import 'package:back_office/model/reserve_ticket_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;

class EditTicketPage extends StatefulWidget {
  final TicketConcertModel ticket;
  final String ticketImagePath;

  EditTicketPage(
      {Key? key, required this.ticket, required this.ticketImagePath})
      : super(key: key);

  @override
  State<EditTicketPage> createState() => _EditTicketPageState();
}

class _EditTicketPageState extends State<EditTicketPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _editedEventName;
  late String _editedImageEvent;
  late String _editedPartnerId;
  late int _editedNumberOfTickets;
  late DateTime _editedEventDate;
  late DateTime _editedOpeningSaleDate;
  late DateTime _editedEndingSaleDate;
  late double _editedTicketPrice;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _editedEventName = widget.ticket.eventName;
    _editedImageEvent = widget.ticket.imageEvent;
    _editedPartnerId = widget.ticket.partnerId;
    _editedNumberOfTickets = widget.ticket.numberOfTickets;
    _editedEventDate = widget.ticket.eventDate;
    _editedOpeningSaleDate = widget.ticket.openingSaleDate;
    _editedEndingSaleDate = widget.ticket.endingSaleDate;
    _editedTicketPrice = widget.ticket.ticketPrice;
  }

  Future<void> _pickImage() async {
    ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(pickedFile.path);
      final String savedImagePath = path.join(directory.path, fileName);
      final File localImage = await File(pickedFile.path).copy(savedImagePath);

      setState(() {
        _imageFile = localImage;
      });
    }
  }

  Widget _buildImage() {
    if (_imageFile != null) {
      return Image.file(
        _imageFile!,
        height: 300,
        fit: BoxFit.cover,
      );
    } else {
      return Image.network(
        widget.ticketImagePath,
        height: 300,
        fit: BoxFit.cover,
      );
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime initialDate,
      ValueChanged<DateTime> onDateSelected) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Date"),
          content: Container(
            height: 300,
            child: dp.DayPicker.single(
              selectedDate: initialDate,
              onChanged: onDateSelected,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              datePickerStyles: dp.DatePickerRangeStyles(),
              datePickerLayoutSettings: dp.DatePickerLayoutSettings(
                maxDayPickerRowCount: 2,
                showPrevMonthEnd: true,
                showNextMonthStart: true,
              ),
              selectableDayPredicate: (date) => true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Ticket: ${widget.ticket.eventName}"),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        _buildImage(),
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: Text(
                            'Change Image',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                style: TextStyle(
                                    fontSize: 26, color: Colors.black),
                                onChanged: (newvalue) {
                                  _editedEventName = newvalue;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Event Name',
                                  labelStyle: TextStyle(
                                    fontSize: 26,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                controller: TextEditingController(
                                    text: widget.ticket.eventName),
                                validator: (newvalue) {
                                  if (newvalue!.isEmpty) {
                                    return 'Please enter event name';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                style: TextStyle(
                                    fontSize: 26, color: Colors.black),
                                onChanged: (newvalue) {
                                  _editedNumberOfTickets =
                                      int.parse(newvalue) ?? 0;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Number of Tickets',
                                  labelStyle: TextStyle(
                                    fontSize: 26,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                controller: TextEditingController(
                                    text: widget.ticket.numberOfTickets
                                        .toString()),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter number of tickets';
                                  } else if (!RegExp(r'^[0-9]+$')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  _selectDate(context, _editedEventDate,
                                      (selectedDate) {
                                    setState(() {
                                      _editedEventDate = selectedDate;
                                    });
                                  });
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Event Date (dd-MM-yyyy)',
                                    labelStyle: TextStyle(
                                      fontSize: 26,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(DateFormat('dd-MM-yyyy')
                                      .format(_editedEventDate)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  _selectDate(context, _editedOpeningSaleDate,
                                      (selectedDate) {
                                    setState(() {
                                      _editedOpeningSaleDate = selectedDate;
                                    });
                                  });
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Opening Sale Date (dd-MM-yyyy)',
                                    labelStyle: TextStyle(
                                      fontSize: 26,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(DateFormat('dd-MM-yyyy')
                                      .format(_editedOpeningSaleDate)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  _selectDate(context, _editedEndingSaleDate,
                                      (selectedDate) {
                                    setState(() {
                                      _editedEndingSaleDate = selectedDate;
                                    });
                                  });
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Ending Sale Date (dd-MM-yyyy)',
                                    labelStyle: TextStyle(
                                      fontSize: 26,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                  child: Text(DateFormat('dd-MM-yyyy')
                                      .format(_editedEndingSaleDate)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                style: TextStyle(
                                    fontSize: 26, color: Colors.black),
                                onChanged: (newvalue) {
                                  _editedTicketPrice =
                                      double.parse(newvalue) ?? 0;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Ticket Price',
                                  labelStyle: TextStyle(
                                    fontSize: 26,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                controller: TextEditingController(
                                    text: widget.ticket.ticketPrice.toString()),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter ticket price';
                                  } else if (!RegExp(r'^[0-9]+(\.[0-9]{1,2})?$')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid price';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                        fontSize: 26, color: Colors.black),
                                  ),
                                ),
                                SizedBox(width: 30),
                                ElevatedButton(
                                  onPressed: _saveForm,
                                  child: Text(
                                    'Save Changes',
                                    style: TextStyle(
                                        fontSize: 26, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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

  void _saveForm() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    _uploadData();
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    final fileName = path.basename(_imageFile!.path);
    final firebase_storage.Reference ref = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('images/$fileName');

    try {
      final firebase_storage.UploadTask uploadTask = ref.putFile(_imageFile!);
      final firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Failed to upload image: $e");
      return null;
    }
  }

  void _uploadData() async {
    String? imageUrl = await _uploadImage();
    final userId =
        Provider.of<MemberUserModel>(context, listen: false).memberUser!.id;

    Map<String, dynamic> updatedData = {
      'partnerId': userId,
      'eventName': _editedEventName,
      'imageEvent': imageUrl ?? widget.ticket.imageEvent,
      'partnerId': _editedPartnerId,
      'numberOfTickets': _editedNumberOfTickets,
      'eventDate': _editedEventDate,
      'openingSaleDate': _editedOpeningSaleDate,
      'endingSaleDate': _editedEndingSaleDate,
      'ticketPrice': _editedTicketPrice,
      'editTime': DateTime.now(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('ticket_concert_catalog')
          .doc(widget.ticket.id)
          .update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_editedEventName updated successfully!'),
          backgroundColor: Colors.green[600],
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      print("Error updating document: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to update $_editedEventName. Please try again.'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }
}
