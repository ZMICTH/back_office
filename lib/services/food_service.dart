import 'package:back_office/model/food_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FoodAndBeverageService {
  Future<List<FoodAndBeverageProduct>> getAllFoodAndBeverageProduct();

  // void updateFoodAndBeverageProduct(
  //     FoodAndBeverageProduct foodandbeverageproduct);
}

class FoodAndBeverageFirebaseService implements FoodAndBeverageService {
  @override
  Future<List<FoodAndBeverageProduct>> getAllFoodAndBeverageProduct() async {
    print("getAllFoodAndBeverageProduct is called");
    QuerySnapshot qs =
        await FirebaseFirestore.instance.collection('food_beverage').get();
    print("Food and Beverage count: ${qs.docs.length}");
    AllFoodAndBeverageProduct FoodAndBeverageProducts =
        AllFoodAndBeverageProduct.fromSnapshot(qs);
    print(FoodAndBeverageProducts.FoodAndBeverageProducts);
    return FoodAndBeverageProducts.FoodAndBeverageProducts;
  }
}
