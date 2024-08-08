import 'dart:io';

import 'package:back_office/component/drawer.dart';
import 'package:back_office/model/food_model.dart';
import 'package:back_office/model/login_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class EditItemPage extends StatefulWidget {
  final FoodAndBeverageProduct item;
  final String itemImagePath;

  EditItemPage({Key? key, required this.item, required this.itemImagePath})
      : super(key: key);

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _editedUnit;
  late String _editedTypeProduct;
  late String _editedProductname;
  late String _editedItem;
  late int _editedQuantity;
  late int _editedPrices;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _editedUnit = _typeunit.contains(widget.item.unit)
        ? widget.item.unit
        : _typeunit.first;
    _editedTypeProduct = _typeproduct.contains(widget.item.type)
        ? widget.item.type
        : _typeproduct.first;
    _editedProductname = widget.item.nameFoodBeverage;
    _editedItem = widget.item.item;
    _editedQuantity = widget.item.quantity;
    _editedPrices = widget.item.priceFoodBeverage;
  }

  var _typeproduct = [
    "normal",
    "promotion",
  ];

  var _typeunit = [
    "Bottle",
    "Dish",
    "Jar",
  ]; // Ensure these values are unique and correctly typed

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
        widget.itemImagePath,
        height: 300,
        fit: BoxFit.cover,
      );
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
        title: Text("Edit item : ${widget.item.nameFoodBeverage}"),
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
                                onChanged: (String newvalue) {
                                  _editedProductname = newvalue;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Product Name',
                                  labelStyle: TextStyle(
                                    fontSize: 26,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                controller: TextEditingController(
                                    text: widget.item.nameFoodBeverage),
                                validator: (newvalue) {
                                  if (newvalue!.isEmpty) {
                                    return 'Please Enter Product Name';
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
                                onChanged: (String newvalue) {
                                  _editedItem = newvalue;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Item in pack',
                                  labelStyle: TextStyle(
                                    fontSize: 26,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                controller: TextEditingController(
                                    text: widget.item.item),
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
                              child: FormField<String>(
                                initialValue:
                                    _editedUnit, // Ensure this is set to prevent the initial value error
                                builder: (FormFieldState<String> state) {
                                  return InputDecorator(
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
                                          color: Colors.redAccent,
                                          fontSize: 16.0),
                                      hintText: 'Please select unit',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                    ),
                                    isEmpty: _editedUnit == '',
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        style: TextStyle(
                                            fontSize: 24, color: Colors.black),
                                        value: _editedUnit,
                                        isDense: true,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _editedUnit = newValue!;
                                            state.didChange(newValue);
                                          });
                                        },
                                        items: _typeunit.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: FormField<String>(
                                initialValue:
                                    _editedTypeProduct, // Ensure this is set to prevent the initial value error
                                builder: (FormFieldState<String> state) {
                                  return InputDecorator(
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
                                          color: Colors.redAccent,
                                          fontSize: 16.0),
                                      hintText: 'Please select type of product',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                    ),
                                    isEmpty: _editedTypeProduct == '',
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        style: TextStyle(
                                            fontSize: 24, color: Colors.black),
                                        value: _editedTypeProduct,
                                        isDense: true,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            print(_editedTypeProduct);
                                            _editedTypeProduct = newValue!;
                                            state.didChange(newValue);
                                          });
                                        },
                                        items: _typeproduct.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                style: TextStyle(
                                    fontSize: 26, color: Colors.black),
                                onChanged: (newvalue) {
                                  setState(() {
                                    _editedQuantity = int.parse(newvalue) ?? 0;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Quantity of product',
                                  labelStyle: TextStyle(
                                      fontSize: 26,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                keyboardType: TextInputType.number,
                                controller: TextEditingController(
                                    text: _editedQuantity.toString()),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Quantity of product';
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
                                    fontSize: 26, color: Colors.black),
                                onChanged: (newvalue) {
                                  setState(() {
                                    _editedPrices = int.parse(newvalue) ?? 0;
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Price of product',
                                  labelStyle: TextStyle(
                                      fontSize: 26,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                keyboardType: TextInputType.number,
                                controller: TextEditingController(
                                    text: _editedPrices.toString()),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Price of product';
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
                                  onPressed: () {
                                    // Add save logic here
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                        fontSize: 26, color: Colors.black),
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
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
    if (_imageFile == null) return null; // If no new image, return null

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
    String? imageUrl = await _uploadImage(); // Upload the image and get URL
    final userId =
        Provider.of<MemberUserModel>(context, listen: false).memberUser!.id;

    // Prepare the data map
    Map<String, dynamic> updatedData = {
      'partnerId': userId,
      'unit': _editedUnit,
      'type': _editedTypeProduct,
      'nameFoodBeverage': _editedProductname,
      'item': _editedItem,
      'quantity': _editedQuantity,
      'priceFoodBeverage': _editedPrices,
      'foodbeverageimagePath': imageUrl ?? widget.item.foodbeverageimagePath,
      'editTime': DateTime.now(),
    };

    // Update the document in Firestore
    try {
      await FirebaseFirestore.instance
          .collection('food_beverage')
          .doc(widget.item.id) // Assuming you have the ID in your item model
          .update(updatedData);
      // Show a SnackBar upon successful data update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$_editedProductname updated successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green[600],
        ),
      );
      Navigator.pop(context); // Navigate back after successful save
    } catch (error) {
      print("Error updating document: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update $_editedProductname. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }
}
