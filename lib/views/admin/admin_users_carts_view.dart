import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/cart_item.dart';
import '../../services/firestore_service.dart';

class AdminUsersCartsView extends StatelessWidget {
  const AdminUsersCartsView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirestoreService().getAllUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: FoodieApp.primaryOrange),
          );
        }
        final userDocs = snapshot.data?.docs ?? [];
        if (userDocs.isEmpty) {
          return const Center(child: Text('No registered users found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: userDocs.length,
          itemBuilder: (context, index) {
            final userDoc = userDocs[index];
            final userData = userDoc.data() as Map<String, dynamic>? ?? {};
            final userName = userData['name'] ?? 'User';
            final userEmail = userData['email'] ?? userDoc.id;

            return StreamBuilder<QuerySnapshot>(
              stream: userDoc.reference.collection('cart').snapshots(),
              builder: (context, cartSnapshot) {
                final cartDocs = cartSnapshot.data?.docs ?? [];
                if (cartDocs.isEmpty) return const SizedBox.shrink();

                final items = cartDocs
                    .map((c) => CartItem.fromFirestore(c))
                    .toList();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$userName ($userEmail)',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Divider(),
                        ...items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${item.food.name} x ${item.quantity}'),
                                Text(
                                  '\$${(item.food.price * item.quantity).toStringAsFixed(2)}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
