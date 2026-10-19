import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';
import '../services/firestore_service.dart';

class AdminViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  int _selectedTabIndex = 0;
  bool _isActionLoading = false;

  int get selectedTabIndex => _selectedTabIndex;
  bool get isActionLoading => _isActionLoading;

  // Stream of all registered user documents
  Stream<QuerySnapshot> get usersStream =>
      _firestoreService.getAllUsersStream();

  // Stream of food items for the catalog view
  Stream<List<FoodItem>> get foodCatalogStream =>
      _firestoreService.getFoodsStream();

  // Stream active cart items for a specific user ID
  Stream<List<CartItem>> getUserCartStream(String userId) {
    return _firestoreService.getUserCartStream(userId);
  }

  void setTabIndex(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  // Create new food item in Firestore catalog
  Future<void> addFoodItem({
    required String name,
    required double price,
    required String imageUrl,
    required VoidCallback onSuccess,
    required Function(String error) onError,
  }) async {
    _isActionLoading = true;
    notifyListeners();

    try {
      final foodItem = FoodItem(
        id: '',
        name: name.trim(),
        price: price,
        imageUrl: imageUrl.trim(),
      );

      await _firestoreService.addFoodItem(foodItem);
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  // Delete food item from catalog
  Future<void> deleteFoodItem({
    required String foodId,
    required VoidCallback onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      await _firestoreService.deleteFoodItem(foodId);
      onSuccess();
    } catch (e) {
      onError(e.toString());
    }
  }
}

final adminViewModel = AdminViewModel();
