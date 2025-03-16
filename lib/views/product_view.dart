import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_preferences.dart';
import '../view_models/product_view_model.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/cart_view_model.dart';
import '../view_models/navigation_view_model.dart';
import 'login_view.dart';
import 'onboarding_view.dart';

class ProductView extends StatelessWidget {
  const ProductView({super.key});

  @override
  Widget build(BuildContext context) {
    final productViewModel = Provider.of<ProductViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);
    final cartViewModel = Provider.of<CartViewModel>(context);
    final Color skyBlue = const Color(0xFF87CEEB);
    final Color dodgerBlue = const Color(0xFF1E90FF);
    final Color deepSkyBlue = const Color(0xFF00BFFF);
    final Color cornflowerBlue = const Color(0xFF6495ED);

    // Load products when the view is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (productViewModel.products.isEmpty) {
        productViewModel.fetchProducts();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: deepSkyBlue,
        centerTitle: true,
        title: const Text(
          'Shop',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Reconnect',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const OnboardingView(isRestart: false)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () {
              authViewModel.logout(Provider.of<AppPreferences>(context, listen: false));
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar with reduced padding
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Container(
                height: 44, // Fixed height for search bar
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    hintStyle: const TextStyle(fontSize: 14),
                    prefixIcon: Icon(
                      Icons.search,
                      color: deepSkyBlue,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ),
            // Categories with reduced height
            SizedBox(
              height: 40, // Reduced height
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip('All', cornflowerBlue, true),
                  _buildCategoryChip('New', dodgerBlue, false),
                  _buildCategoryChip('Popular', dodgerBlue, false),
                  _buildCategoryChip('Trending', dodgerBlue, false),
                  _buildCategoryChip('Sale', dodgerBlue, false),
                ],
              ),
            ),
            const SizedBox(height: 4), // Reduced spacing
            // Products grid
            Expanded(
              child: productViewModel.isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  color: deepSkyBlue,
                ),
              )
                  : productViewModel.errorMessage.isNotEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 56,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error Loading Products',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      productViewModel.errorMessage,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  : GridView.builder(
                padding: const EdgeInsets.all(12), // Reduced padding
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75, // Adjusted for better fit
                  crossAxisSpacing: 12, // Reduced spacing
                  mainAxisSpacing: 12, // Reduced spacing
                ),
                itemCount: productViewModel.products.length,
                itemBuilder: (context, index) {
                  final product = productViewModel.products[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product image with like button overlay - shorter height
                        Stack(
                          children: [
                            // Product image
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Container(
                                height: 120, // Reduced height
                                width: double.infinity,
                                color: skyBlue.withOpacity(0.2),
                                child: Image.asset(
                                  product.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.image,
                                        size: 40, // Reduced size
                                        color: deepSkyBlue.withOpacity(0.5),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Favorite button - smaller
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                height: 24, // Fixed small size
                                width: 24, // Fixed small size
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    // Add favorite functionality here
                                  },
                                  child: Icon(
                                    Icons.favorite_border,
                                    size: 14,
                                    color: Colors.red.shade300,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Product details - more compact
                        Padding(
                          padding: const EdgeInsets.all(8.0), // Reduced padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13, // Smaller text
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2), // Reduced spacing
                              // Rating stars - more compact
                              Row(
                                children: [
                                  Icon(Icons.star, size: 12, color: Colors.amber[700]),
                                  Icon(Icons.star, size: 12, color: Colors.amber[700]),
                                  Icon(Icons.star, size: 12, color: Colors.amber[700]),
                                  Icon(Icons.star, size: 12, color: Colors.amber[700]),
                                  Icon(Icons.star_half, size: 12, color: Colors.amber[700]),
                                  const SizedBox(width: 2),
                                  Text(
                                    '4.5',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4), // Reduced spacing
                              // Price and add to cart
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14, // Smaller text
                                      color: deepSkyBlue,
                                    ),
                                  ),
                                  Container(
                                    height: 28, // Fixed height
                                    width: 28, // Fixed width
                                    decoration: BoxDecoration(
                                      color: deepSkyBlue,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: 14, // Smaller icon
                                      icon: const Icon(
                                        Icons.add_shopping_cart,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        cartViewModel.addToCart(product);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: deepSkyBlue,
                                            content: Text('${product.name} added to cart'),
                                            behavior: SnackBarBehavior.floating,
                                            action: SnackBarAction(
                                              label: 'VIEW',
                                              textColor: Colors.white,
                                              onPressed: () {
                                                Provider.of<NavigationViewModel>(context, listen: false)
                                                    .setCurrentIndex(3);
                                              },
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, Color color, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0), // Reduced padding
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12, // Smaller text
            color: isSelected ? Colors.white : color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedColor: color,
        backgroundColor: Colors.grey.shade100,
        checkmarkColor: Colors.white,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: isSelected ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
        ),
        onSelected: (bool selected) {
          // Category selection logic
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce tap target size
        visualDensity: VisualDensity.compact, // More compact layout
      ),
    );
  }
}