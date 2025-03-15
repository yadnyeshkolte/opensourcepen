// lib/views/cart_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../view_models/cart_view_model.dart';
import '../view_models/product_view_model.dart';
import '../view_models/auth_view_model.dart';
import 'checkout_view.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  @override
  void initState() {
    super.initState();

    // Initialize cart when view is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
      final productViewModel = Provider.of<ProductViewModel>(context, listen: false);
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

      if (cartViewModel.cart == null) {
        cartViewModel.initializeCart(
          authViewModel.user?.id ?? 'guest',
          productViewModel.products,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<CartViewModel>(
        builder: (context, cartViewModel, child) {
          if (cartViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartViewModel.errorMessage.isNotEmpty) {
            return Center(child: Text(cartViewModel.errorMessage));
          }

          if (cartViewModel.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add items to your cart to start shopping',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartViewModel.itemCount,
                  itemBuilder: (context, index) {
                    final cartItem = cartViewModel.cart!.items[index];
                    return CartItemWidget(
                      cartItem: cartItem,
                      onIncrement: () {
                        final productViewModel = Provider.of<ProductViewModel>(context, listen: false);
                        cartViewModel.updateQuantity(
                          cartItem.product.id,
                          cartItem.quantity + 1,
                          productViewModel.products,
                        );
                      },
                      onDecrement: () {
                        if (cartItem.quantity > 1) {
                          final productViewModel = Provider.of<ProductViewModel>(context, listen: false);
                          cartViewModel.updateQuantity(
                            cartItem.product.id,
                            cartItem.quantity - 1,
                            productViewModel.products,
                          );
                        }
                      },
                      onRemove: () {
                        final productViewModel = Provider.of<ProductViewModel>(context, listen: false);
                        cartViewModel.removeItem(
                          cartItem.product.id,
                          productViewModel.products,
                        );
                      },
                    );
                  },
                ),
              ),
              CartSummary(
                subtotal: cartViewModel.subtotal,
                tax: cartViewModel.tax,
                total: cartViewModel.total,
                onCheckout: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckoutView(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItemModel cartItem;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.cartItem,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Image.network(
                  cartItem.product.imageUrl,
                  width: 60,
                  height: 60,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${cartItem.product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Quantity controls
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: onDecrement,
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              padding: EdgeInsets.zero,
                            ),
                            SizedBox(
                              width: 30,
                              child: Center(
                                child: Text(
                                  '${cartItem.quantity}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: onIncrement,
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Item total
                      Text(
                        '\$${cartItem.itemTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Remove button
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onRemove,
              color: Colors.red[400],
            ),
          ],
        ),
      ),
    );
  }
}

class CartSummary extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double total;
  final VoidCallback onCheckout;

  const CartSummary({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary rows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text('\$${subtotal.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tax (8.5%)'),
              Text('\$${tax.toStringAsFixed(2)}'),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Checkout button
          ElevatedButton(
            onPressed: onCheckout,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: Colors.white,
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text('PROCEED TO CHECKOUT'),
          ),
        ],
      ),
    );
  }
}