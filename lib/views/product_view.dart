import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/product_view_model.dart';
import '../view_models/auth_view_model.dart';
import 'login_view.dart';

class ProductView extends StatelessWidget {
  const ProductView({super.key});

  @override
  Widget build(BuildContext context) {
    final productViewModel = Provider.of<ProductViewModel>(context);
    final authViewModel = Provider.of<AuthViewModel>(context);

    // Load products when the view is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (productViewModel.products.isEmpty) {
        productViewModel.fetchProducts();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authViewModel.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
              );
            },
          ),
        ],
      ),
      body: productViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : productViewModel.errorMessage.isNotEmpty
          ? Center(child: Text(productViewModel.errorMessage))
          : ListView.builder(
        itemCount: productViewModel.products.length,
        itemBuilder: (context, index) {
          final product = productViewModel.products[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(product.name),
              subtitle: Text(product.description),
              trailing: Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}