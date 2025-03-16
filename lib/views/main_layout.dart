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
      Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF87CEEB).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: Color(0xFF1E90FF),
              ),
              const SizedBox(height: 16),
              const Text(
                'Software Access Locked',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4682B4),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Complete onboarding to access Software features',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
      const ProductView(),
      const CartView(),
      const OrdersView(),
    ];

    return Scaffold(
      body: screens[navigationViewModel.currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: navigationViewModel.currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF00BFFF),
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                activeIcon: Icon(Icons.home_rounded, size: 28),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.developer_mode_rounded),
                activeIcon: Icon(Icons.developer_mode_rounded, size: 28),
                label: 'Software',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_rounded),
                activeIcon: Icon(Icons.shopping_bag_rounded, size: 28),
                label: 'Products',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_rounded),
                activeIcon: Icon(Icons.shopping_cart_rounded, size: 28),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_rounded),
                activeIcon: Icon(Icons.receipt_rounded, size: 28),
                label: 'Orders',
              ),
            ],
            onTap: (index) {
              // Check if software is enabled before allowing navigation
              if (index == 1 && !navigationViewModel.softwareEnabled) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Complete onboarding to access Software'),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF4682B4),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(10),
                    duration: const Duration(seconds: 3),
                  ),
                );
                return;
              }
              navigationViewModel.setCurrentIndex(index);
            },
          ),
        ),
      ),
    );
  }
}