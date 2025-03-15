import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartViewModel extends ChangeNotifier {
  List<CartItemModel> _cartItems = [];

  List<CartItemModel> get cartItems => _cartItems;

  double get total => _cartItems.fold(
      0, (sum, item) => sum + item.totalPrice);

  int get itemCount => _cartItems.length;

  bool get isEmpty => _cartItems.isEmpty;

  void addToCart(ProductModel product, {int quantity = 1}) {
    // Check if the product is already in cart
    final existingItemIndex = _cartItems.indexWhere(
            (item) => item.productId == product.id);

    if (existingItemIndex >= 0) {
      // Update quantity of existing item
      final existingItem = _cartItems[existingItemIndex];
      final updatedItem = CartItemModel(
        productId: existingItem.productId,
        name: existingItem.name,
        price: existingItem.price,
        quantity: existingItem.quantity + quantity,
      );
      _cartItems[existingItemIndex] = updatedItem;
    } else {
      // Add new item
      _cartItems.add(CartItemModel(
        productId: product.id,
        name: product.name,
        price: product.price,
        quantity: quantity,
      ));
    }

    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _cartItems.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        final item = _cartItems[index];
        _cartItems[index] = CartItemModel(
          productId: item.productId,
          name: item.name,
          price: item.price,
          quantity: quantity,
        );
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems = [];
    notifyListeners();
  }
}