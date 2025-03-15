import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/cart_model.dart';

class OrderViewModel extends ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isEmpty => _orders.isEmpty;

  // Example method to place an order
  Future<void> placeOrder(List<CartItemModel> cartItems, double total) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call with delay
      await Future.delayed(const Duration(seconds: 1));

      // Create new order
      final order = OrderModel(
        id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        items: List.from(cartItems),
        total: total,
        orderDate: DateTime.now(),
        status: 'processing',
      );

      // Add order to the list
      _orders.add(order);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to place order: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Mock method to fetch orders
  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, you would fetch from an API
      // For now, we'll just use mock data if none exists
      if (_orders.isEmpty) {
        _orders = _getMockOrders();
      }
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to fetch orders: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Mock data for orders
  List<OrderModel> _getMockOrders() {
    return [
      OrderModel(
        id: 'ORD-12345',
        items: [
          CartItemModel(
            productId: '1',
            name: 'Product 1',
            price: 99.99,
            quantity: 1,
          ),
        ],
        total: 99.99,
        orderDate: DateTime.now().subtract(const Duration(days: 5)),
        status: 'delivered',
      ),
      OrderModel(
        id: 'ORD-67890',
        items: [
          CartItemModel(
            productId: '2',
            name: 'Product 2',
            price: 149.99,
            quantity: 2,
          ),
          CartItemModel(
            productId: '3',
            name: 'Product 3',
            price: 199.99,
            quantity: 1,
          ),
        ],
        total: 499.97,
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        status: 'shipped',
      ),
    ];
  }
}