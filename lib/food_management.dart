import 'package:back_office/component/drawer.dart';
import 'package:back_office/component/edit_food.dart';
import 'package:back_office/controller/food_controller.dart';
import 'package:back_office/model/food_model.dart';
import 'package:back_office/model/login_model.dart';
import 'package:back_office/services/food_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FoodAndBeverageManagement extends StatefulWidget {
  @override
  State<FoodAndBeverageManagement> createState() =>
      _FoodAndBeverageManagementState();
}

class _FoodAndBeverageManagementState extends State<FoodAndBeverageManagement> {
  late FoodAndBeverageController foodandbeveragecontroller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    foodandbeveragecontroller =
        FoodAndBeverageController(FoodAndBeverageFirebaseService());
    _loadFoodAndBeverageProducts();
  }

  Future<void> _loadFoodAndBeverageProducts() async {
    try {
      final userId =
          Provider.of<MemberUserModel>(context, listen: false).memberUser!.id;
      var products =
          await foodandbeveragecontroller.fetchFoodAndBeverageProduct();

      // Filter orders where userId == partnerId and paymentStatus is false
      products = products.where((order) => order.partnerId == userId).toList();

      Provider.of<ProductModel>(context, listen: false)
          .setFoodAndBeverageProducts(products);
    } catch (e) {
      print('Error fetching FoodProduct: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final productModel = Provider.of<ProductModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Text("Food and Beverage Management"),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/newfood');
                                },
                                child: const Text(
                                  "Add New Product",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          _buildProductSection(
                              "Promotion Product", productModel.promotions),
                          SizedBox(height: 16),
                          _buildProductSection(
                              "Normal Product", productModel.normals),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductSection(
      String title, List<FoodAndBeverageProduct> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        ),
        SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(20.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            Color cardColor;
            String stockText;
            Color colorText;

            if (item.quantity == 0) {
              cardColor = Colors.red[200]!;
              stockText = "Out of stock";
              colorText = Colors.red;
            } else if (item.quantity <= 10) {
              cardColor = Colors.orange[300]!;
              stockText = "Low inventories";
              colorText = Colors.white;
            } else {
              cardColor = Colors.grey[400]!;
              stockText = 'In Stocks ${item.quantity} ${item.unit}';
              colorText = Colors.white;
            }

            return SingleChildScrollView(
              child: Card(
                color: cardColor,
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        item.foodbeverageimagePath,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Text(
                          '${item.nameFoodBeverage} ${item.item} ${item.unit}'),
                      Text('Price is ${item.priceFoodBeverage} THB'),
                      Text(stockText,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: colorText)),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () {
                                print(
                                    "Edit tapped for ${item.nameFoodBeverage}");
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => EditItemPage(
                                      item: item,
                                      itemImagePath: item.foodbeverageimagePath,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "Edit",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Confirm Delete"),
                                      content: Text(
                                          "Are you sure you want to delete ${item.nameFoodBeverage}?"),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text("Cancel"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text("Delete",
                                              style:
                                                  TextStyle(color: Colors.red)),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog first
                                            _deleteProduct(
                                                item); // Then proceed to delete
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
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
            );
          },
        ),
      ],
    );
  }

  void _deleteProduct(FoodAndBeverageProduct item) async {
    try {
      await FirebaseFirestore.instance
          .collection('food_beverage')
          .doc(item.id) // Assuming 'id' is the document ID in your model
          .delete();

      // Optionally, refresh the list or show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${item.nameFoodBeverage} deleted successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[600],
        ),
      );

      // Refresh the list after deletion
      _loadFoodAndBeverageProducts();
    } catch (e) {
      print('Error deleting product: $e');
      // Optionally, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete ${item.nameFoodBeverage}',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red[600],
        ),
      );
    }
  }
}
