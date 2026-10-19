import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'Are you sure you want to permanently delete your account? All your data, profile, and cart history will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await cartViewModel.deleteUserAccount();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red[700],
              content: Text('Failed to delete account: $e'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? const Color(0xFF333333)
        : const Color(0xFFE0E0E0);
    final user = AuthService().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.all(20),
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: user != null
                ? FirestoreService().getUserStream(user.uid)
                : null,
            builder: (context, snapshot) {
              if (snapshot.hasData && user != null && !snapshot.data!.exists) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  authViewModel.logout();
                });
              }

              String name = 'Foodie User';
              String email = user?.email ?? 'No email';
              String phone = 'No phone registered';

              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                name = data['name'] ?? name;
                email = data['email'] ?? email;
                phone = data['phone'] ?? phone;
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&q=70',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            phone,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Account',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Column(
              children: [
                _settingsTile(
                  Icons.person_outline,
                  'Personal Information',
                  isDark,
                ),
                Divider(height: 1, color: borderColor),
                _settingsTile(Icons.location_on_outlined, 'Addresses', isDark),
                Divider(height: 1, color: borderColor),
                _settingsTile(
                  Icons.credit_card_outlined,
                  'Payment Methods',
                  isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Preferences',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.2),
            ),
            child: Column(
              children: [
                ListenableBuilder(
                  listenable: cartViewModel,
                  builder: (context, _) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.notifications_none,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      title: const Text(
                        'Notifications',
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing: Switch.adaptive(
                        value: cartViewModel.notificationsEnabled,
                        activeColor: Colors.white,
                        activeTrackColor: FoodieApp.primaryOrange,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: isDark
                            ? Colors.grey[800]
                            : Colors.grey[300],
                        onChanged: (val) =>
                            cartViewModel.toggleNotifications(val),
                      ),
                    );
                  },
                ),
                Divider(height: 1, color: borderColor),
                ListenableBuilder(
                  listenable: themeViewModel,
                  builder: (context, _) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.dark_mode_outlined,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      title: const Text(
                        'Dark Mode',
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing: Switch.adaptive(
                        value: themeViewModel.themeMode == ThemeMode.dark,
                        activeColor: Colors.white,
                        activeTrackColor: FoodieApp.primaryOrange,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: isDark
                            ? Colors.grey[800]
                            : Colors.grey[300],
                        onChanged: (val) => themeViewModel.toggleTheme(val),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => authViewModel.logout(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: FoodieApp.primaryOrange),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: FoodieApp.primaryOrange,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _confirmDeleteAccount(context),
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            label: const Text(
              'Delete Account',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, bool isDark) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isDark ? Colors.white : Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
      onTap: () {},
    );
  }
}
