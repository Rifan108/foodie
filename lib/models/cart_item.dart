import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_item.dart';

class CartItem {
  final FoodItem food;
  int quantity;

  CartItem({required this.food, this.quantity = 1});

  factory CartItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    double parsedPrice = 0.0;
    final rawPrice = data['price'];
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      parsedPrice =
          double.tryParse(rawPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    }

    return CartItem(
      food: FoodItem(
        id: doc.id,
        name: data['name']?.toString() ?? '',
        price: parsedPrice,
        imageUrl:
            data['image_url']?.toString() ?? data['imageUrl']?.toString() ?? '',
      ),
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}
