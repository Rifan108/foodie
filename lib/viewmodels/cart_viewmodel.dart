import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();

  bool notificationsEnabled = true;
  int unreadNotificationsCount = 0;

  List<CartItem> _cartItems = [];
  StreamSubscription<List<CartItem>>? _cartSubscription;
  String? _activeUserId;
  bool _foregroundNotificationsConfigured = false;

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  void bindUserCart(String userId) {
    if (_activeUserId == userId) return;
    _activeUserId = userId;
    _cartSubscription?.cancel();

    _cartSubscription = _firestoreService.getUserCartStream(userId).listen((
      items,
    ) {
      _cartItems = items;
      notifyListeners();
    });
  }

  void unbindUserCart() {
    _cartSubscription?.cancel();
    _cartSubscription = null;
    _activeUserId = null;
    _cartItems = [];
    notifyListeners();
  }

  void setupForegroundNotificationListener() {
    if (_foregroundNotificationsConfigured) return;
    _foregroundNotificationsConfigured = true;
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      unreadNotificationsCount++;
      _persistUnreadCount();
      notifyListeners();

      if (notificationsEnabled) {
        final title =
            message.notification?.title ??
            message.data['title'] ??
            'Foodie Alert 🔔';
        final body =
            message.notification?.body ??
            message.data['body'] ??
            'You have a new update!';
        _notificationService.showNotification(
          id: message.hashCode,
          title: title,
          body: body,
        );
      }
    });
  }

  Future<void> loadUnreadNotifications() async {
    final preferences = await SharedPreferences.getInstance();
    unreadNotificationsCount =
        preferences.getInt(NotificationService.unreadCountKey) ?? 0;
    notifyListeners();
  }

  Future<void> refreshUnreadNotifications() => loadUnreadNotifications();

  Future<void> _persistUnreadCount() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(
      NotificationService.unreadCountKey,
      unreadNotificationsCount,
    );
  }

  void clearNotifications() {
    unreadNotificationsCount = 0;
    _persistUnreadCount();
    notifyListeners();
  }

  void toggleNotifications(bool val) {
    notificationsEnabled = val;
    notifyListeners();
  }

  Future<bool> addToCart(FoodItem item) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return false;

    final existing = _cartItems.where((c) => c.food.id == item.id).firstOrNull;
    if (existing != null) {
      if (existing.quantity < 10) {
        await _firestoreService.updateCartQuantity(
          uid,
          item.id,
          existing.quantity + 1,
        );
        return true;
      }
      return false;
    } else {
      await _firestoreService.setCartItem(uid, item, 1);
      return true;
    }
  }

  Future<void> incrementQuantity(String id) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    final existing = _cartItems.where((c) => c.food.id == id).firstOrNull;
    if (existing != null && existing.quantity < 10) {
      await _firestoreService.updateCartQuantity(
        uid,
        id,
        existing.quantity + 1,
      );
    }
  }

  Future<void> decrementQuantity(String id) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    final existing = _cartItems.where((c) => c.food.id == id).firstOrNull;
    if (existing != null && existing.quantity > 1) {
      await _firestoreService.updateCartQuantity(
        uid,
        id,
        existing.quantity - 1,
      );
    }
  }

  Future<void> removeItem(String id) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    await _firestoreService.removeCartItem(uid, id);
  }

  Future<void> clearCart() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    await _firestoreService.clearCart(uid);
  }

  Future<void> deleteUserAccount() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    await clearCart();
    await _firestoreService.deleteUserProfile(uid);
    await _authService.deleteCurrentUser();
    unbindUserCart();
  }

  double get subtotal => _cartItems.fold(
    0.0,
    (sum, item) => sum + (item.food.price * item.quantity),
  );

  double get deliveryFee => _cartItems.isEmpty ? 0.00 : 2.99;
  double get total => subtotal + deliveryFee;
  int get totalItemCount =>
      _cartItems.fold(0, (count, item) => count + item.quantity);
}

final cartViewModel = CartViewModel();
