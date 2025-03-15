// lib/services/cart_service.dart
import 'dart:convert';
import '../data/mock_data.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartService {
  // In a real implementation, this would interact with an API
  // For now, we'll use in-memory data structures

  // Get the current cart for a user
  Future<CartModel> getCart(String userId, List<ProductModel> availableProducts) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay

    try {
      if (MockData.userCart.isEmpty) {
        // Initialize empty cart if it doesn't exist
        return CartModel.empty(userId);
      }

      return CartModel.fromJson(MockData.userCart, availableProducts);
    } catch (e) {
      throw Exception('Failed to get cart: ${e.toString()}');
    }
  }

  // Add item to cart
  Future<CartModel> addToCart(CartModel cart, ProductModel product, int quantity, List<ProductModel> availableProducts) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay

    try {
      // Check if product already exists in cart
      final existingItemIndex = cart.items.indexWhere((item) => item.product.id == product.id);

      if (existingItemIndex >= 0) {
        // Update quantity of existing item
        cart.items[existingItemIndex].quantity += quantity;
      } else {
        // Add new item
        cart.items.add(CartItemModel(product: product, quantity: quantity));
      }

      // Recalculate totals
      cart.recalculateTotals();

      // Update the mock data
      MockData.userCart = cart.toJson();

      return cart;
    } catch (e) {
      throw Exception('Failed to add to cart: ${e.toString()}');
    }
  }

  // Update cart item quantity
  Future<CartModel> updateCartItemQuantity(CartModel cart, String productId, int quantity, List<ProductModel> availableProducts) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay

    try {
      // Find item in cart
      final itemIndex = cart.items.indexWhere((item) => item.product.id == productId);

      if (itemIndex < 0) {
        throw Exception('Product not found in cart');
      }

      if (quantity <= 0) {
        // Remove item if quantity is zero or negative
        cart.items.removeAt(itemIndex);
      } else {
        // Update quantity
        cart.items[itemIndex].quantity = quantity;
      }

      // Recalculate totals
      cart.recalculateTotals();

      // Update the mock data
      MockData.userCart = cart.toJson();

      return cart;
    } catch (e) {
      throw Exception('Failed to update cart: ${e.toString()}');
    }
  }

  // Remove item from cart
  Future<CartModel> removeFromCart(CartModel cart, String productId, List<ProductModel> availableProducts) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay

    try {
      // Remove item
      cart.items.removeWhere((item) => item.product.id == productId);

      // Recalculate totals
      cart.recalculateTotals();

      // Update the mock data
      MockData.userCart = cart.toJson();

      return cart;
    } catch (e) {
      throw Exception('Failed to remove from cart: ${e.toString()}');
    }
  }

  // Clear cart
  Future<CartModel> clearCart(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay

    try {
      // Create empty cart
      final emptyCart = CartModel.empty(userId);

      // Update the mock data
      MockData.userCart = emptyCart.toJson();

      return emptyCart;
    } catch (e) {
      throw Exception('Failed to clear cart: ${e.toString()}');
    }
  }
}