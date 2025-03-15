// lib/view_models/order_view_model.dart
import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../services/order_service.dart';
import '../data/mock_data.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = [];
  OrderModel? _currentOrder;
  List<ShippingMethod> _shippingMethods = [];
  OrderAddress? _shippingAddress;
  bool _isLoading = false;
  String _errorMessage = '';

  List<OrderModel> get orders => _orders;
  OrderModel? get currentOrder => _currentOrder;
  List<ShippingMethod> get shippingMethods => _shippingMethods;
  OrderAddress? get shippingAddress => _shippingAddress;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Load user orders
  Future<void> loadOrders(String userId, List<ProductModel> availableProducts) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _orders = await _orderService.getOrders(userId, availableProducts);
    } catch (e) {
      _errorMessage = 'Failed to load orders: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get order by ID
  Future<void> getOrderById(String orderId, List<ProductModel> availableProducts) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _currentOrder = await _orderService.getOrderById(orderId, availableProducts);
    } catch (e) {
      _errorMessage = 'Failed to get order: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load shipping methods
  Future<void> loadShippingMethods() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // In a real app, this would be loaded from an API
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay

      _shippingMethods = MockData.availableShippingMethods.map((json) => ShippingMethod(
        id: json['id'],
        name: json['name'],
        price: json['price'],
        estimatedDelivery: json['estimatedDelivery'],
      )).toList();
    } catch (e) {
      _errorMessage = 'Failed to load shipping methods: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load shipping address
  Future<void> loadShippingAddress() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // In a real app, this would be loaded from an API
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay

      final addressData = MockData.shippingAddress;
      _shippingAddress = OrderAddress(
        fullName: addressData['fullName'],
        addressLine1: addressData['addressLine1'],
        addressLine2: addressData['addressLine2'],
        city: addressData['city'],
        state: addressData['state'],
        postalCode: addressData['postalCode'],
        country: addressData['country'],
        phoneNumber: addressData['phoneNumber'],
      );
    } catch (e) {
      _errorMessage = 'Failed to load shipping address: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create order from cart
  Future<OrderModel?> createOrder({
    required CartModel cart,
    required String shippingMethodId,
    required String paymentMethodId,
    required List<ProductModel> availableProducts,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Ensure shipping address is loaded
      if (_shippingAddress == null) {
        await loadShippingAddress();
      }

      // Find selected shipping method
      final selectedShippingMethod = _shippingMethods.firstWhere(
            (method) => method.id == shippingMethodId,
        orElse: () => throw Exception('Shipping method not found'),
      );

      // Create order
      _currentOrder = await _orderService.createOrder(
        cart: cart,
        shippingAddress: _shippingAddress!,
        shippingMethod: selectedShippingMethod,
        paymentMethodId: paymentMethodId,
        availableProducts: availableProducts,
      );

      // Reload orders list
      await loadOrders(cart.userId, availableProducts);

      return _currentOrder;
    } catch (e) {
      _errorMessage = 'Failed to create order: ${e.toString()}';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId, List<ProductModel> availableProducts) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _currentOrder = await _orderService.cancelOrder(orderId, availableProducts);

      // Reload orders list to reflect changes
      if (_orders.isNotEmpty) {
        final userId = _orders.first.userId;
        await loadOrders(userId, availableProducts);
      }

      return true;
    } catch (e) {
      _errorMessage = 'Failed to cancel order: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}