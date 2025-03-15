import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/navigation_view_model.dart';
import 'home_view.dart';
import 'software_view.dart';
import 'product_view.dart';
import 'cart_view.dart';
import 'orders_view.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationViewModel = Provider.of<NavigationViewModel>(context);

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

}