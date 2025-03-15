import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/navigation_view_model.dart';
import '../view_models/auth_view_model.dart';
import '../services/app_preferences.dart';
import 'home_view.dart';
import 'software_view.dart';
import 'product_view.dart';
import 'cart_view.dart';
import 'orders_view.dart';
import 'login_view.dart';
import 'onboarding_view.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationViewModel = Provider.of<NavigationViewModel>(context);
    final appPreferences = Provider.of<AppPreferences>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);

    // Determine which screens to show based on preferences
    final List<Widget> screens = [
      const HomeView(),
      navigationViewModel.softwareEnabled ? const SoftwareView() :
      const Center(child: Text('Complete onboarding to access Software')),
      const ProductView(),
      const CartView(),
      const OrdersView(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: _getTitle(navigationViewModel.currentIndex),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Restart Onboarding',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OnboardingView(isRestart: true)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authViewModel.logout(appPreferences);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
              );
            },
          ),
        ],
      ),
      body: screens[navigationViewModel.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationViewModel.currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.developer_mode), label: 'Software'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Orders'),
        ],
        onTap: (index) {
          // Check if software is enabled before allowing navigation
          if (index == 1 && !navigationViewModel.softwareEnabled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Complete onboarding to access Software')),
            );
            return;
          }
          navigationViewModel.setCurrentIndex(index);
        },
      ),
    );
  }

  Widget _getTitle(int index) {
    switch (index) {
      case 0: return const Text('Home');
      case 1: return const Text('Software');
      case 2: return const Text('Products');
      case 3: return const Text('Cart');
      case 4: return const Text('Orders');
      default: return const Text('App');
    }
  }
}