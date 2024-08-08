import 'dart:io';

import 'package:back_office/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  String emailUser = '';
  String passwordUser = '';
  String partnerName = '';
  String partnerPhone = '';
  String contactName = '';
  String taxId = '';
  int totalSeats = 0;
  List<Map<String, dynamic>> tableLabels = [];
  File? _selectedFile;
  String? _uploadURL;

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
          title: const Text(
            "Add New Table Type",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 26,
                  ),
                  controller: labelController,
                  decoration: const InputDecoration(
                    hintText: "Label",
                    labelStyle: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                TextField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 26,
                  ),
                  controller: seatsController,
                  decoration: const InputDecoration(
                    hintText: "Seats",
                    labelStyle: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    updateNumberOfChairs();
                  },
                ),
                TextField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 26,
                  ),
                  controller: totalOfTableController,
                  decoration: const InputDecoration(
                    hintText: "Total of Table",
                    labelStyle: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    updateNumberOfChairs();
                  },
                ),
                TextField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 26,
                  ),
                  controller: numberOfChairsController,
                  decoration: const InputDecoration(
                    hintText: "Number of Chairs",
                    labelStyle: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: false, // Make this field read-only
                ),
                TextField(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 26,
                  ),
                  controller: tablePriceController,
                  decoration: const InputDecoration(
                    hintText: "Table Price",
                    labelStyle: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 22,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Add',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 22,
                ),
              ),
              onPressed: () {
                if (labelController.text.isNotEmpty &&
                    numberOfChairsController.text.isNotEmpty &&
                    seatsController.text.isNotEmpty &&
                    tablePriceController.text.isNotEmpty &&
                    totalOfTableController.text.isNotEmpty) {
                  setState(() {
                    tableLabels.add({
                      'label': labelController.text,
                      'numberofchairs':
                          int.parse(numberOfChairsController.text),
                      'seats': int.parse(seatsController.text),
                      'tablePrices': double.parse(tablePriceController.text),
                      'totaloftable': int.parse(totalOfTableController.text),
                    });
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

  void _deleteTableLabel(int index) {
    setState(() {
      tableLabels.removeAt(index);
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('uploads/${_selectedFile!.path.split('/').last}');
        final uploadTask = storageRef.putFile(_selectedFile!);

        final snapshot = await uploadTask.whenComplete(() {});
        final downloadURL = await snapshot.ref.getDownloadURL();

        setState(() {
          _uploadURL = downloadURL;
        });

        print('File uploaded successfully. Download URL: $_uploadURL');
      } catch (e) {
        print('Failed to upload file: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        title: Text('Register User'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'image/logo.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 26,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'E-mail',
                      labelStyle: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    validator: MultiValidator([
                      RequiredValidator(errorText: "Please enter your Email"),
                      EmailValidator(errorText: "Wrong pattern Email"),
                    ]),
                    onSaved: (newEmailUser) {
                      emailUser = newEmailUser!;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 26,
                    ),
                    obscureText: true,
                    inputFormatters: [LengthLimitingTextInputFormatter(15)],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      labelStyle: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Password';
                      }
                      if (value.length < 8) {
                        return 'Weak password';
                      }
                      return null;
                    },
                    onSaved: (newPasswordUser) {
                      passwordUser = newPasswordUser!;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 26,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Partner Name',
                      labelStyle: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Partner Name';
                      }
                      return null;
                    },
                    onSaved: (newPartnerName) {
                      partnerName = newPartnerName!;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 26,
                    ),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Partner Phone',
                      labelStyle: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Partner Phone';
                      }
                      return null;
                    },
                    onSaved: (newPartnerPhone) {
                      partnerPhone = newPartnerPhone!;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 26,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Contact Name',
                      labelStyle: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Contact Name';
                      }
                      return null;
                    },
                    onSaved: (newContactName) {
                      contactName = newContactName!;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 26,
                    ),
                    inputFormatters: [LengthLimitingTextInputFormatter(13)],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Tax ID',
                      labelStyle: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Tax ID';
                      }
                      if (value.length < 13) {
                        return 'Tax ID must be 13 characters';
                      }
                      return null;
                    },
                    onSaved: (newTaxId) {
                      taxId = newTaxId!;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 26,
                    ),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Total Seats',
                      labelStyle: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the Total Seats';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Total Seats must be a number';
                      }
                      return null;
                    },
                    onSaved: (newTotalSeats) {
                      totalSeats = int.parse(newTotalSeats!);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _addNewTableLabel,
                            child: Text(
                              'Add Table Label',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ), // Increased font size
                          ),
                        ],
                      ),
                      Wrap(
                        children: tableLabels
                            .map((label) => Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Chip(
                                    label: Text(
                                      "${label['label']}: Seats - ${label['seats']}, Tables - ${label['totaloftable']}, Total Seats - ${label['numberofchairs']}, Price - ${label['tablePrices'].toStringAsFixed(2)} THB",
                                      style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onDeleted: () {
                                      setState(() {
                                        tableLabels.remove(label);
                                      });
                                    },
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: _pickFile,
                        child: Text(
                          'Attach File',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_selectedFile != null)
                        Text(
                          'Selected File: ${_selectedFile!.path.split('/').last}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (_uploadURL != null)
                        Text(
                          'File Uploaded: $_uploadURL',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      await _uploadFile();
                      try {
                        await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                          email: emailUser,
                          password: passwordUser,
                        );

                        User? user = FirebaseAuth.instance.currentUser;

                        if (user != null) {
                          await user.updateProfile(
                              displayName: 'Display Name', photoURL: null);

                          await FirebaseFirestore.instance
                              .collection('partner')
                              .doc(user.uid)
                              .set({
                            'emailUser': emailUser,
                            'partnerName': partnerName,
                            'partnerPhone': partnerPhone,
                            'contactName': contactName,
                            'taxId': taxId,
                            'totalSeats': totalSeats,
                            'tableLabels': tableLabels,
                            'userStatus': "Inactive",
                            'fileURL': _uploadURL,
                            'role': "partner",
                          });
                        }

                        _formKey.currentState!.reset();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      } on FirebaseAuthException catch (e) {
                        print(e.message);
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                'Registration Error',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20, // Increased font size
                                ),
                              ),
                              content: Text(
                                e.message ?? "An unknown error occurred",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18), // Increased font size
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('OK',
                                      style: TextStyle(
                                          fontSize: 18)), // Increased font size
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    textStyle: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold), // Increased font size
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
