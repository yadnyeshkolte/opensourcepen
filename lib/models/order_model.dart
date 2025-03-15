import 'cart_model.dart';

class OrderModel {
  final String id;
  final List<CartItemModel> items;
  final double total;
  final DateTime orderDate;
  final String status; // "pending", "processing", "shipped", "delivered"

  OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.orderDate,
    required this.status,
  });
}