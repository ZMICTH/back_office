import 'dart:io';

import 'package:back_office/component/drawer.dart';
import 'package:back_office/model/login_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';

import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class AddTicketPage extends StatefulWidget {
  @override
  State<AddTicketPage> createState() => _AddTicketPageState();
}

class _AddTicketPageState extends State<AddTicketPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _eventName;
  late String _imageEvent;
  late int _numberOfTickets;
  late DateTime _eventDate;
  late DateTime _openingSaleDate;
  late DateTime _endingSaleDate;
  late double _ticketPrice;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    final totalSeats = Provider.of<MemberUserModel>(context, listen: false)
        .memberUser!
        .totalSeats;
    _eventName = '';
    _imageEvent = '';
    _numberOfTickets = totalSeats;
    _eventDate = DateTime.now();
    _openingSaleDate = DateTime.now();
    _endingSaleDate = DateTime.now();
    _ticketPrice = 0.0;
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
      return Container(
        height: 300,
        color: Colors.grey[200],
        child: Icon(
          Icons.image,
          size: 100,
          color: Colors.grey[400],
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime initialDate,
      ValueChanged<DateTime> onDateSelected) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
      keyboardType: TextInputType.datetime,
    );

    if (pickedDate != null && pickedDate != initialDate) {
      onDateSelected(pickedDate);
    }
  }

  @override
  void dispose() {
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
                            'Select Image',
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
                                  _eventName = newvalue;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Event Name',
                                  labelStyle: TextStyle(
                                    fontSize: 26,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
                                initialValue: _numberOfTickets.toString(),
                                readOnly: true, // Make the field read-only
                                decoration: InputDecoration(
                                  labelText: 'Number of Tickets',
                                  labelStyle: TextStyle(
                                    fontSize: 26,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  _selectDate(context, _eventDate,
                                      (selectedDate) {
                                    setState(() {
                                      _eventDate = selectedDate;
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
                                      .format(_eventDate)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  _selectDate(context, _openingSaleDate,
                                      (selectedDate) {
                                    setState(() {
                                      _openingSaleDate = selectedDate;
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
                                      .format(_openingSaleDate)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  _selectDate(context, _endingSaleDate,
                                      (selectedDate) {
                                    setState(() {
                                      _endingSaleDate = selectedDate;
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
                                      .format(_endingSaleDate)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                style: TextStyle(
                                    fontSize: 26, color: Colors.black),
                                onChanged: (newvalue) {
                                  _ticketPrice = double.parse(newvalue) ?? 0;
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
                                    'Add Ticket',
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
    if (_eventDate == _endingSaleDate) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            content:
                Text('Event date and ending sale date cannot be the same.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    String? imageUrl = await _uploadImage();
    final userId =
        Provider.of<MemberUserModel>(context, listen: false).memberUser!.id;

    Map<String, dynamic> newTicketData = {
      'eventName': _eventName,
      'imageEvent': imageUrl ?? '',
      'partnerId': userId,
      'numberOfTickets': _numberOfTickets,
      'eventDate': _eventDate,
      'openingSaleDate': _openingSaleDate,
      'endingSaleDate': _endingSaleDate,
      'ticketPrice': _ticketPrice,
    };

    try {
      await FirebaseFirestore.instance
          .collection('ticket_concert_catalog')
          .add(newTicketData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_eventName added successfully!'),
          backgroundColor: Colors.green[600],
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      print("Error adding document: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add $_eventName. Please try again.'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }
}
