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

      // Mock data
      _products = [
        ProductModel(
          id: '1',
          name: 'Product 1',
          description: 'Description for product 1',
          price: 99.99,
          imageUrl: 'https://via.placeholder.com/150',
        ),
        ProductModel(
          id: '2',
          name: 'Product 2',
          description: 'Description for product 2',
          price: 149.99,
          imageUrl: 'https://via.placeholder.com/150',
        ),
        ProductModel(
          id: '3',
          name: 'Product 3',
          description: 'Description for product 3',
          price: 199.99,
          imageUrl: 'https://via.placeholder.com/150',
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