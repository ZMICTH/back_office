import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FoodAndBeverageProduct {
  String id = "";
  late String nameFoodBeverage;
  late int priceFoodBeverage;
  String foodbeverageimagePath;
  late String item;
  late String unit;
  String type;
  late int quantity;
  String partnerId;

  FoodAndBeverageProduct(
    this.nameFoodBeverage,
    this.priceFoodBeverage,
    this.foodbeverageimagePath,
    this.item,
    this.unit,
    this.type,
    this.quantity,
    this.partnerId,
  );
  factory FoodAndBeverageProduct.fromJson(Map<String, dynamic> json) {
    print("FoodAndBeverageProduct.fromJson");
    print(json);
    return FoodAndBeverageProduct(
      json['nameFoodBeverage'] as String,
      json['priceFoodBeverage'] as int,
      json['foodbeverageimagePath'] as String,
      json['item'] as String,
      json['unit'] as String,
      json['type'] as String,
      json['quantity'] as int,
      json['partnerId'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': nameFoodBeverage,
      'price': priceFoodBeverage,
      'imagePath': foodbeverageimagePath,
      'item': item,
      'unit': unit,
      'type': type,
      'quantity': quantity,
      'partnerId': partnerId,
    };
  }
}

class AllFoodAndBeverageProduct {
  final List<FoodAndBeverageProduct> FoodAndBeverageProducts;

  AllFoodAndBeverageProduct(
      this.FoodAndBeverageProducts); // for Todo read each list from json

  factory AllFoodAndBeverageProduct.fromJson(List<dynamic> json) {
    List<FoodAndBeverageProduct> FoodAndBeverageProducts;

    FoodAndBeverageProducts =
        json.map((item) => FoodAndBeverageProduct.fromJson(item)).toList();

    return AllFoodAndBeverageProduct(FoodAndBeverageProducts);
  }

  factory AllFoodAndBeverageProduct.fromSnapshot(QuerySnapshot qs) {
    List<FoodAndBeverageProduct> FoodAndBeverageProducts;

    FoodAndBeverageProducts = qs.docs.map((DocumentSnapshot ds) {
      FoodAndBeverageProduct foodandbeverageproduct =
          FoodAndBeverageProduct.fromJson(ds.data() as Map<String, dynamic>);
      foodandbeverageproduct.id = ds.id;
      return foodandbeverageproduct;
    }).toList();

    return AllFoodAndBeverageProduct(FoodAndBeverageProducts);
  }
}

class ProductModel extends ChangeNotifier {
  List<FoodAndBeverageProduct> _foodAndBeverageProducts = [];
  List<FoodAndBeverageProduct> _normals = [];
  List<FoodAndBeverageProduct> _promotions = [];

  final List _cart = [];

  List<FoodAndBeverageProduct> get normals => _normals;
  List<FoodAndBeverageProduct> get promotions => _promotions;
  get cart => _cart;

  void setFoodAndBeverageProducts(
      List<FoodAndBeverageProduct> foodAndBeverageProducts) {
    _foodAndBeverageProducts = foodAndBeverageProducts;
    _filterProductsAndPromotions();
    notifyListeners();
  }

  void _filterProductsAndPromotions() {
    _normals = _foodAndBeverageProducts
        .where((product) => product.type == 'normal')
        .toList();
    _promotions = _foodAndBeverageProducts
        .where((product) => product.type == 'promotion')
        .toList();
  }

  void filterByPartnerId(String partnerId) {
    _foodAndBeverageProducts = _foodAndBeverageProducts
        .where((product) => product.partnerId == partnerId)
        .toList();
    _filterProductsAndPromotions();
    notifyListeners();
  }
}
