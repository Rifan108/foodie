import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../services/firestore_service.dart';

class FoodCatalogViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  Stream<List<FoodItem>> get foodsStream => _firestoreService.getFoodsStream();

  Future<void> addFood({
    required String name,
    required double price,
    required String imageUrl,
  }) {
    final item = FoodItem(id: '', name: name, price: price, imageUrl: imageUrl);
    return _firestoreService.addFoodItem(item);
  }

  Future<void> deleteFood(String id) {
    return _firestoreService.deleteFoodItem(id);
  }
}

final foodCatalogViewModel = FoodCatalogViewModel();
