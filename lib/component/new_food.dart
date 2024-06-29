import 'dart:io';

import 'package:back_office/component/drawer.dart';
import 'package:back_office/model/login_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:provider/provider.dart';

class NewProductPage extends StatefulWidget {
  @override
  State<NewProductPage> createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _newUnit;
  late String _newTypeProduct;
  late String _newProductname;
  late String _newItem;
  late int _newQuantity;
  late int _newPrices;
  late String itemImagePath;
  File? _imageFile;

  var _typeproduct = [
    "normal",
    "promotion",
  ];

  var _typeunit = ["Bottle", "Dish", "Jar"];

  @override
  void initState() {
    super.initState();
    _newUnit = _typeunit.first;
    _newTypeProduct = _typeproduct.first;
    _newProductname = '';
    _newItem = '';
    _newQuantity = 0;
    _newPrices = 0;
  }

  // Function to handle image picking
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
      return const Placeholder(fallbackHeight: 300);
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
        title: Text("Add New Product"),
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
              // Move between page
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
                            'Add Image',
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
                                    fontSize: 24, color: Colors.black),
                                onChanged: (value) => _newProductname = value,
                                decoration: InputDecoration(
                                  labelText: 'Product Name',
                                  labelStyle: TextStyle(
                                    fontSize: 26,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                validator: (value) => value!.isEmpty
                                    ? 'Please enter product name'
                                    : null,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                style: TextStyle(
                                    fontSize: 26, color: Colors.black),
                                onChanged: (value) => _newItem = value,
                                decoration: InputDecoration(
                                  labelText: 'Item in pack',
                                  labelStyle: TextStyle(
                                    fontSize: 26,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter item in pack';
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
                              child: DropdownButtonFormField(
                                style: TextStyle(
                                    fontSize: 24, color: Colors.black),
                                value: _newUnit,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _newUnit = newValue!;
                                  });
                                },
                                items: _typeunit.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                decoration: InputDecoration(
                                  label: Text(
                                    'Unit',
                                    style: TextStyle(
                                        fontSize: 30, color: Colors.black),
                                  ),
                                  labelStyle: TextStyle(
                                    fontSize: 26,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  errorStyle: TextStyle(
                                      color: Colors.redAccent, fontSize: 16.0),
                                  hintText: 'Please select unit',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DropdownButtonFormField(
                                style: TextStyle(
                                    fontSize: 24, color: Colors.black),
                                value: _newTypeProduct,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _newTypeProduct = newValue!;
                                  });
                                },
                                items: _typeproduct
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                decoration: InputDecoration(
                                  label: Text(
                                    'Type of product',
                                    style: TextStyle(
                                        fontSize: 30, color: Colors.black),
                                  ),
                                  labelStyle: TextStyle(
                                    fontSize: 26,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  errorStyle: TextStyle(
                                      color: Colors.redAccent, fontSize: 16.0),
                                  hintText: 'Please select type of product',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                style: TextStyle(
                                    fontSize: 24, color: Colors.black),
                                onChanged: (value) =>
                                    _newQuantity = int.tryParse(value) ?? 0,
                                decoration: InputDecoration(
                                  labelText: 'Quantity of product',
                                  labelStyle: TextStyle(
                                    fontSize: 26,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter quantity of product';
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
                              child: TextFormField(
                                style: TextStyle(
                                    fontSize: 24, color: Colors.black),
                                onChanged: (value) =>
                                    _newPrices = int.tryParse(value) ?? 0,
                                decoration: InputDecoration(
                                  labelText: 'Price of product',
                                  labelStyle: TextStyle(
                                    fontSize: 26,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter price of product';
                                  } else if (!RegExp(r'^[0-9]+$')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid number';
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
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                                SizedBox(width: 30),
                                ElevatedButton(
                                  onPressed: _saveForm,
                                  child: Text('Save Product'),
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
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _uploadData(); // Ensure this is called inside the validation block
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null; // If no new image, return null

    final fileName = path.basename(_imageFile!.path);
    final firebase_storage.Reference ref = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('images/$fileName');

    try {
      // Upload the image to Firebase Storage
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
    String? imageUrl = await _uploadImage(); // Upload the image and get URL
    final userId =
        Provider.of<MemberUserModel>(context, listen: false).memberUser!.id;

    // Prepare the data map
    Map<String, dynamic> newData = {
      'partnerId': userId,
      'unit': _newUnit,
      'type': _newTypeProduct,
      'nameFoodBeverage': _newProductname,
      'item': _newItem,
      'quantity': _newQuantity,
      'priceFoodBeverage': _newPrices,
      'foodbeverageimagePath': imageUrl,
      'addTime': DateTime.now(),
    };

    // Update the document in Firestore
    try {
      await FirebaseFirestore.instance.collection('food_beverage').add(newData);
      // Show a SnackBar upon successful data save
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$_newProductname added successfully!'),
          backgroundColor: Colors.green[600],
        ),
      );
      Navigator.pop(context); // Navigate back after successful save
    } catch (error) {
      print("Error adding document: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add $_newProductname. Please try again.'),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }
}
