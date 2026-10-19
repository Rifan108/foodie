import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;

  const FoodItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  factory FoodItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    double parsedPrice = 0.0;
    final rawPrice = data['price'] ?? data['cost'] ?? data['amount'];
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice is String) {
      parsedPrice =
          double.tryParse(rawPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    }

    return FoodItem(
      id: doc.id,
      name:
          data['name']?.toString() ?? data['title']?.toString() ?? 'Food Item',
      price: parsedPrice,
      imageUrl:
          data['image_url']?.toString() ??
          data['imageUrl']?.toString() ??
          data['image']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'image_url': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
