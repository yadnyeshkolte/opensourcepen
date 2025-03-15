import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductViewModel extends ChangeNotifier {
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call with delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data with local asset paths
      _products = [
        ProductModel(
          id: '1',
          name: 'Product 1',
          description: 'Description for product 1',
          price: 99.99,
          imageUrl: 'assets/product_images/1.png',
        ),
        ProductModel(
          id: '2',
          name: 'Product 2',
          description: 'Description for product 2',
          price: 149.99,
          imageUrl: 'assets/product_images/2.png',
        ),
        ProductModel(
          id: '3',
          name: 'Product 3',
          description: 'Description for product 3',
          price: 199.99,
          imageUrl: 'assets/product_images/3.png',
        ),
        ProductModel(
          id: '4',
          name: 'Product 4',
          description: 'Description for product 4',
          price: 19.99,
          imageUrl: 'assets/product_images/4.png',
        ),
        ProductModel(
          id: '5',
          name: 'Product 5',
          description: 'Description for product 5',
          price: 299.99,
          imageUrl: 'assets/product_images/5.png',
        ),
        ProductModel(
          id: '6',
          name: 'Product 6',
          description: 'Description for product 6',
          price: 149.99,
          imageUrl: 'assets/product_images/6.png',
        ),
        ProductModel(
          id: '7',
          name: 'Product 7',
          description: 'Description for product 7',
          price: 129.99,
          imageUrl: 'assets/product_images/7.png',
        ),
        ProductModel(
          id: '8',
          name: 'Product 8',
          description: 'Description for product 8',
          price: 119.99,
          imageUrl: 'assets/product_images/8.png',
        ),
      ];
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to fetch products: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }
}