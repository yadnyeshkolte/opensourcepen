// lib/models/payment_model.dart

enum PaymentMethodType {
  creditCard,
  paypal,
  applePay,
  googlePay,
  bankTransfer
}

class PaymentMethodModel {
  final String id;
  final PaymentMethodType type;
  final String name;
  final bool isDefault;
  final Map<String, dynamic> details;

  PaymentMethodModel({
    required this.id,
    required this.type,
    required this.name,
    this.isDefault = false,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'name': name,
      'isDefault': isDefault,
      'details': details,
    };
  }

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'],
      type: PaymentMethodType.values.firstWhere(
              (e) => e.toString().split('.').last == json['type'],
          orElse: () => PaymentMethodType.creditCard),
      name: json['name'],
      isDefault: json['isDefault'] ?? false,
      details: json['details'] ?? {},
    );
  }
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  cancelled
}

class PaymentTransactionModel {
  final String transactionId;
  final String orderId;
  final double amount;
  final PaymentStatus status;
  final String paymentMethodId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? failureReason;

  PaymentTransactionModel({
    required this.transactionId,
    required this.orderId,
    required this.amount,
    required this.status,
    required this.paymentMethodId,
    required this.createdAt,
    this.completedAt,
    this.failureReason,
  });

  Map<String, dynamic> toJson() {
    return {
    'transactionId': transactionId,
    'orderId': orderId,
    'amount': amount,
      'status': status.toString().split('.').last,
      'paymentMethodId': paymentMethodId,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'failureReason': failureReason,
    };
  }

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionModel(
      transactionId: json['transactionId'],
      orderId: json['orderId'],
      amount: json['amount'],
      status: PaymentStatus.values.firstWhere(
              (e) => e.toString().split('.').last == json['status'],
          orElse: () => PaymentStatus.pending),
      paymentMethodId: json['paymentMethodId'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      failureReason: json['failureReason'],
    );
  }

  factory PaymentTransactionModel.createFromOrder(String orderId, double amount, String paymentMethodId) {
    return PaymentTransactionModel(
      transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      amount: amount,
      status: PaymentStatus.pending,
      paymentMethodId: paymentMethodId,
      createdAt: DateTime.now(),
    );
  }

  PaymentTransactionModel copyWith({
    PaymentStatus? status,
    DateTime? completedAt,
    String? failureReason,
  }) {
    return PaymentTransactionModel(
      transactionId: this.transactionId,
      orderId: this.orderId,
      amount: this.amount,
      status: status ?? this.status,
      paymentMethodId: this.paymentMethodId,
      createdAt: this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      failureReason: failureReason ?? this.failureReason,
    );
  }
}