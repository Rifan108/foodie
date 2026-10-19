import 'package:flutter/material.dart';
import '../../main.dart';
import '../../models/food_item.dart';
import '../../viewmodels/food_catalog_viewmodel.dart';

class AdminFoodCatalogView extends StatelessWidget {
  const AdminFoodCatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FoodItem>>(
      stream: foodCatalogViewModel.foodsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: FoodieApp.primaryOrange),
          );
        }
        final foods = snapshot.data ?? [];
        if (foods.isEmpty) {
          return const Center(child: Text('No food items in catalog'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: foods.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final food = foods[index];
            return Material(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    food.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.fastfood),
                  ),
                ),
                title: Text(
                  food.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('\$${food.price.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => foodCatalogViewModel.deleteFood(food.id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
