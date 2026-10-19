import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/notification_service.dart';
import 'viewmodels/cart_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'views/admin/admin_dashboard_view.dart';
import 'views/auth/welcome_auth_view.dart';
import 'views/main_navigation_view.dart'; // Corrected import path

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService().initialize(
    onNotificationTapped: () => cartViewModel.clearNotifications(),
  );

  await cartViewModel.loadUnreadNotifications();
  cartViewModel.setupForegroundNotificationListener();
  AppLifecycleListener(
    onResume: cartViewModel.refreshUnreadNotifications,
  );
  await FirestoreService().seedInitialFoodsIfEmpty();

  runApp(const FoodieApp());
}

class FoodieApp extends StatelessWidget {
  const FoodieApp({super.key});

  static const Color primaryOrange = Color(0xFFFF4B26);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeViewModel,
      builder: (context, _) {
        return MaterialApp(
          title: 'Foodie',
          debugShowCheckedModeBanner: false,
          themeMode: themeViewModel.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF9F9FB),
            cardColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryOrange,
              primary: primaryOrange,
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryOrange,
              primary: primaryOrange,
              brightness: Brightness.dark,
            ),
          ),
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: FoodieApp.primaryOrange),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          final email = (user.email ?? '').toLowerCase().trim();

          if (email == 'admin@admin.com') {
            return const AdminDashboardView();
          }

          cartViewModel.bindUserCart(user.uid);
          return const MainNavigationView(); // Corrected class name
        }

        cartViewModel.unbindUserCart();
        return const WelcomeAuthView();
      },
    );
  }
}
