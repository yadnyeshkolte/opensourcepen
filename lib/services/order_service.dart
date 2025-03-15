// lib/services/order_service.dart
import 'dart:convert';
import '../data/mock_data.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class OrderService {
  // In a real implementation, this would interact with an API
  // For now, we'll use in-memory data structures

  // Get all orders for a user
  Future<List<OrderModel>> getOrders(String userId, List<ProductModel> availableProducts) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    try {
      final ordersList = <OrderModel>[];

      for (final orderJson in MockData.orders) {
        // Convert order items from JSON to CartItemModel objects
        final cartItems = (orderJson['items'] as List)
            .map((itemJson) => CartItemModel.fromJson(itemJson, availableProducts))
            .toList();

        // Create OrderModel from JSON and cartItems
        ordersList.add(OrderModel.fromJson(orderJson, cartItems));
      }

      // Filter orders by userId
      return ordersList.where((order) => order.userId == userId).toList();
    } catch (e) {
      throw Exception('Failed to get orders: ${e.toString()}');
    }
  }

  // Get a specific order by ID
  Future<OrderModel?> getOrderById(String orderId, List<ProductModel> availableProducts) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay

    try {
      // Find order in mock data
      final orderJson = MockData.orders.firstWhere(
            (order) => order['orderId'] == orderId,
        orElse: () => throw Exception('Order not found'),
      );

      // Convert order items from JSON to CartItemModel objects
      final cartItems = (orderJson['items'] as List)
          .map((itemJson) => CartItemModel.fromJson(itemJson, availableProducts))
          .toList();

      // Create OrderModel from JSON and cartItems
      return OrderModel.fromJson(orderJson, cartItems);
    } catch (e) {
      throw Exception('Failed to get order: ${e.toString()}');
    }
  }

  // Create an order from cart
  Future<OrderModel> createOrder({
    required CartModel cart,
    required OrderAddress shippingAddress,
    required ShippingMethod shippingMethod,
    required String paymentMethodId,
    required List<ProductModel> availableProducts,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700)); // Simulate network delay

    try {
      // Generate order ID
      final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';

      // Create order from cart
      final order = OrderModel.fromCart(
        cart: cart,
        orderId: orderId,
        shippingAddress: shippingAddress,
        shippingMethod: shippingMethod,
        paymentMethodId: paymentMethodId,
      );

      // Add order to mock data
      MockData.orders.add(order.toJson());

      return order;
    } catch (e) {
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }

  // Update order status
  Future<OrderModel> updateOrderStatus(String orderId, OrderStatus newStatus, List<ProductModel> availableProducts) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    try {
      // Find order index in mock data
      final orderIndex = MockData.orders.indexWhere(
            (order) => order['orderId'] == orderId,
      );

      if (orderIndex < 0) {
        throw Exception('Order not found');
      }

      // Update status
      MockData.orders[orderIndex]['status'] = newStatus.toString().split('.').last;

      // Update dates based on status
      final now = DateTime.now().toIso8601String();

      switch (newStatus) {
        case OrderStatus.processing:
          MockData.orders[orderIndex]['processedDate'] = now;
          break;
        case OrderStatus.shipped:
          MockData.orders[orderIndex]['shippedDate'] = now;
          break;
        case OrderStatus.delivered:
          MockData.orders[orderIndex]['deliveredDate'] = now;
          break;
        default:
          break;
      }

      // Convert order items from JSON to CartItemModel objects
      final cartItems = (MockData.orders[orderIndex]['items'] as List)
          .map((itemJson) => CartItemModel.fromJson(itemJson, availableProducts))
          .toList();

      // Return updated order
      return OrderModel.fromJson(MockData.orders[orderIndex], cartItems);
    } catch (e) {
      throw Exception('Failed to update order status: ${e.toString()}');
    }
  }

  // Cancel order
  Future<OrderModel> cancelOrder(String orderId, List<ProductModel> availableProducts) async {
    return updateOrderStatus(orderId, OrderStatus.cancelled, availableProducts);
  }
}