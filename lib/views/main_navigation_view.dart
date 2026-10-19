import 'package:flutter/material.dart';
import '../../main.dart';
import '../../viewmodels/cart_viewmodel.dart';
import 'cart/cart_view.dart';
import 'home/home_view.dart';
import 'profile/profile_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [HomeView(), CartView(), ProfileView()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: ListenableBuilder(
        listenable: cartViewModel,
        builder: (context, _) {
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            selectedItemColor: FoodieApp.primaryOrange,
            unselectedItemColor: Colors.grey,
            elevation: 8,
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  label: Text('${cartViewModel.totalItemCount}'),
                  isLabelVisible: cartViewModel.totalItemCount > 0,
                  backgroundColor: FoodieApp.primaryOrange,
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                activeIcon: Badge(
                  label: Text('${cartViewModel.totalItemCount}'),
                  isLabelVisible: cartViewModel.totalItemCount > 0,
                  backgroundColor: FoodieApp.primaryOrange,
                  child: const Icon(Icons.shopping_cart),
                ),
                label: 'Cart',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}
