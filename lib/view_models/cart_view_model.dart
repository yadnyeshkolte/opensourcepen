// lib/view_models/cart_view_model.dart
import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';

class CartViewModel extends ChangeNotifier {
  final CartService _cartService = CartService();

  CartModel? _cart;
  bool _isLoading = false;
  String _errorMessage = '';

  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get itemCount => _cart?.items.length ?? 0;
  double get subtotal => _cart?.subtotal ?? 0.0;
  double get tax => _cart?.tax ?? 0.0;
  double get total => _cart?.total ?? 0.0;
  bool get isEmpty => itemCount == 0;

  // Initialize cart for user
  Future<void> initializeCart(String userId, List<ProductModel> availableProducts) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _cart = await _cartService.getCart(userId, availableProducts);
    } catch (e) {
      _errorMessage = 'Failed to load cart: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add item to cart
  Future<void> addToCart(ProductModel product, int quantity, List<ProductModel> availableProducts) async {
    if (_cart == null) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _cart = await _cartService.addToCart(_cart!, product, quantity, availableProducts);
    } catch (e) {
      _errorMessage = 'Failed to add to cart: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update item quantity
  Future<void> updateQuantity(String productId, int quantity, List<ProductModel> availableProducts) async {
    if (_cart == null) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _cart = await _cartService.updateCartItemQuantity(_cart!, productId, quantity, availableProducts);
    } catch (e) {
      _errorMessage = 'Failed to update quantity: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove item from cart
  Future<void> removeItem(String productId, List<ProductModel> availableProducts) async {
    if (_cart == null) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _cart = await _cartService.removeFromCart(_cart!, productId, availableProducts);
    } catch (e) {
      _errorMessage = 'Failed to remove item: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    if (_cart == null) return;

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _cart = await _cartService.clearCart(_cart!.userId);
    } catch (e) {
      _errorMessage = 'Failed to clear cart: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}