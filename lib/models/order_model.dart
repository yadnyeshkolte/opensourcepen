// lib/models/order_model.dart
import 'cart_model.dart';

enum OrderStatus {
  created,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded
}

class OrderAddress {
  final String fullName;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String phoneNumber;

  OrderAddress({
    required this.fullName,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'phoneNumber': phoneNumber,
    };
  }

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      fullName: json['fullName'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      country: json['country'],
      phoneNumber: json['phoneNumber'],
    );
  }
}

class ShippingMethod {
  final String id;
  final String name;
  final double price;
  final String estimatedDelivery;

  ShippingMethod({
    required this.id,
    required this.name,
    required this.price,
    required this.estimatedDelivery,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'estimatedDelivery': estimatedDelivery,
    };
  }

  factory ShippingMethod.fromJson(Map<String, dynamic> json) {
    return ShippingMethod(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      estimatedDelivery: json['estimatedDelivery'],
    );
  }
}

class OrderModel {
  final String orderId;
  final String userId;
  final List<CartItemModel> items;
  final double subtotal;
  final double tax;
  final double shippingCost;
  final double total;
  final OrderStatus status;
  final OrderAddress shippingAddress;
  final ShippingMethod shippingMethod;
  final String paymentMethodId;
  final DateTime orderDate;
  final DateTime? processedDate;
  final DateTime? shippedDate;
  final DateTime? deliveredDate;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shippingCost,
    required this.total,
    required this.status,
    required this.shippingAddress,
    required this.shippingMethod,
    required this.paymentMethodId,
    required this.orderDate,
    this.processedDate,
    this.shippedDate,
    this.deliveredDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'shippingCost': shippingCost,
      'total': total,
      'status': status.toString().split('.').last,
      'shippingAddress': shippingAddress.toJson(),
      'shippingMethod': shippingMethod.toJson(),
      'paymentMethodId': paymentMethodId,
      'orderDate': orderDate.toIso8601String(),
      'processedDate': processedDate?.toIso8601String(),
      'shippedDate': shippedDate?.toIso8601String(),
      'deliveredDate': deliveredDate?.toIso8601String(),
    };
  }

  factory OrderModel.fromJson(Map<String, dynamic> json, List<CartItemModel> cartItems) {
    return OrderModel(
      orderId: json['orderId'],
      userId: json['userId'],
      items: cartItems,
      subtotal: json['subtotal'],
      tax: json['tax'],
      shippingCost: json['shippingCost'],
      total: json['total'],
      status: OrderStatus.values.firstWhere(
              (e) => e.toString().split('.').last == json['status'],
          orElse: () => OrderStatus.created),
      shippingAddress: OrderAddress.fromJson(json['shippingAddress']),
      shippingMethod: ShippingMethod.fromJson(json['shippingMethod']),
      paymentMethodId: json['paymentMethodId'],
      orderDate: DateTime.parse(json['orderDate']),
      processedDate: json['processedDate'] != null
          ? DateTime.parse(json['processedDate'])
          : null,
      shippedDate: json['shippedDate'] != null
          ? DateTime.parse(json['shippedDate'])
          : null,
      deliveredDate: json['deliveredDate'] != null
          ? DateTime.parse(json['deliveredDate'])
          : null,
    );
  }

  factory OrderModel.fromCart({
    required CartModel cart,
    required String orderId,
    required OrderAddress shippingAddress,
    required ShippingMethod shippingMethod,
    required String paymentMethodId,
  }) {
    return OrderModel(
      orderId: orderId,
      userId: cart.userId,
      items: cart.items,
      subtotal: cart.subtotal,
      tax: cart.tax,
      shippingCost: shippingMethod.price,
      total: cart.total + shippingMethod.price,
      status: OrderStatus.created,
      shippingAddress: shippingAddress,
      shippingMethod: shippingMethod,
      paymentMethodId: paymentMethodId,
      orderDate: DateTime.now(),
    );
  }
}