// lib/models/cart_model.dart
import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;
  double get itemTotal => product.price * quantity;

  CartItemModel({
    required this.product,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': product.id,
      'name': product.name,
      'price': product.price,
      'quantity': quantity,
      'itemTotal': itemTotal,
    };
  }

  static CartItemModel fromJson(Map<String, dynamic> json, List<ProductModel> allProducts) {
    // Find the product in the product list
    final product = allProducts.firstWhere(
          (p) => p.id == json['productId'],
      orElse: () => ProductModel(
        id: json['productId'],
        name: json['name'],
        description: '',
        price: json['price'],
        imageUrl: 'https://via.placeholder.com/150',
      ),
    );

    return CartItemModel(
      product: product,
      quantity: json['quantity'],
    );
  }
}

class CartModel {
  String cartId;
  String userId;
  List<CartItemModel> items;
  double subtotal;
  double tax;
  double total;
  DateTime createdAt;
  DateTime updatedAt;

  CartModel({
    required this.cartId,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartModel.empty(String userId) {
    final now = DateTime.now();
    return CartModel(
      cartId: 'cart_${now.millisecondsSinceEpoch}',
      userId: userId,
      items: [],
      subtotal: 0.0,
      tax: 0.0,
      total: 0.0,
      createdAt: now,
      updatedAt: now,
    );
  }

  void recalculateTotals() {
    subtotal = items.fold(0, (sum, item) => sum + item.itemTotal);
    // Apply tax rate of 8.5%
    tax = subtotal * 0.085;
    total = subtotal + tax;
    updatedAt = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'cartId': cartId,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static CartModel fromJson(Map<String, dynamic> json, List<ProductModel> allProducts) {
    return CartModel(
      cartId: json['cartId'],
      userId: json['userId'],
      items: (json['items'] as List)
          .map((itemJson) => CartItemModel.fromJson(itemJson, allProducts))
          .toList(),
      subtotal: json['subtotal'],
      tax: json['tax'],
      total: json['total'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}