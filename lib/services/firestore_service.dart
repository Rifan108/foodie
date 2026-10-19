import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_item.dart';
import '../models/cart_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<FoodItem>> getFoodsStream() {
    return _db
        .collection('foods')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => FoodItem.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addFoodItem(FoodItem item) {
    return _db.collection('foods').add(item.toMap());
  }

  Future<void> deleteFoodItem(String id) {
    return _db.collection('foods').doc(id).delete();
  }

  Future<void> seedInitialFoodsIfEmpty() async {
    try {
      final snapshot = await _db.collection('foods').limit(1).get();
      if (snapshot.docs.isEmpty) {
        final defaultFoods = [
          {
            'name': 'Margherita Pizza',
            'price': 12.99,
            'image_url':
                'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=300&q=70',
          },
          {
            'name': 'Cheese Burger',
            'price': 8.99,
            'image_url':
                'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300&q=70',
          },
          {
            'name': 'French Fries',
            'price': 3.49,
            'image_url':
                'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=300&q=70',
          },
          {
            'name': 'Veg Sandwich',
            'price': 6.49,
            'image_url':
                'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=300&q=70',
          },
          {
            'name': 'Caesar Salad',
            'price': 7.99,
            'image_url':
                'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=300&q=70',
          },
          {
            'name': 'Chocolate Cake',
            'price': 5.99,
            'image_url':
                'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=300&q=70',
          },
        ];
        for (var food in defaultFoods) {
          await _db.collection('foods').add(food);
        }
      }
    } catch (_) {}
  }

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String email,
  }) {
    return _db.collection('users').doc(uid).set({
      'name': name,
      'phone': phone,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<DocumentSnapshot> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  Future<void> deleteUserProfile(String uid) {
    return _db.collection('users').doc(uid).delete();
  }

  Stream<List<CartItem>> getUserCartStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('cart')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => CartItem.fromFirestore(doc)).toList(),
        );
  }

  Future<void> setCartItem(String uid, FoodItem item, int quantity) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(item.id)
        .set({
          'name': item.name,
          'price': item.price,
          'image_url': item.imageUrl,
          'quantity': quantity,
        });
  }

  Future<void> updateCartQuantity(String uid, String itemId, int quantity) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(itemId)
        .update({'quantity': quantity});
  }

  Future<void> removeCartItem(String uid, String itemId) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('cart')
        .doc(itemId)
        .delete();
  }

  Future<void> clearCart(String uid) async {
    final batch = _db.batch();
    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('cart')
        .get();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Stream<QuerySnapshot> getAllUsersStream() {
    return _db.collection('users').snapshots();
  }
}
