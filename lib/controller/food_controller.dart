import 'dart:async';
import 'package:back_office/model/food_model.dart';
import 'package:back_office/services/food_service.dart';

class FoodAndBeverageController {
  List<FoodAndBeverageProduct> FoodAndBeverageProducts = List.empty();
  final FoodAndBeverageService service;

  StreamController<bool> onSyncController = StreamController();
  Stream<bool> get onSync => onSyncController.stream;

  FoodAndBeverageController(this.service);

  Future<List<FoodAndBeverageProduct>> fetchFoodAndBeverageProduct() async {
    print("fetchFoodAndBeverageProduct was: ${FoodAndBeverageProducts}");
    onSyncController.add(true);
    FoodAndBeverageProducts = await service.getAllFoodAndBeverageProduct();
    onSyncController.add(false);
    return FoodAndBeverageProducts;
  }
}
