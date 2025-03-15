// lib/services/payment_service.dart
import 'dart:convert';
import 'dart:math';
import '../data/mock_data.dart';
import '../models/payment_model.dart';

class PaymentService {
  // In a real implementation, this would interact with an API
  // For now, we'll use in-memory data structures

  // Store for mock payment transactions
  static List<Map<String, dynamic>> _paymentTransactions = [];

  // Get available payment methods
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    try {
      return MockData.paymentMethods.map((json) => PaymentMethodModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get payment methods: ${e.toString()}');
    }
  }

  // Get payment method by ID
  Future<PaymentMethodModel?> getPaymentMethodById(String paymentMethodId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay

    try {
      final methodJson = MockData.paymentMethods.firstWhere(
            (method) => method['id'] == paymentMethodId,
        orElse: () => throw Exception('Payment method not found'),
      );

      return PaymentMethodModel.fromJson(methodJson);
    } catch (e) {
      throw Exception('Failed to get payment method: ${e.toString()}');
    }
  }

  // Process payment
  Future<PaymentTransactionModel> processPayment({
    required String orderId,
    required double amount,
    required String paymentMethodId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1500)); // Simulate payment processing delay

    try {
      // Create payment transaction
      final transaction = PaymentTransactionModel.createFromOrder(
        orderId,
        amount,
        paymentMethodId,
      );

      // Simulate success/failure (90% success rate)
      final random = Random();
      final isSuccess = random.nextDouble() < 0.9;

      final updatedTransaction = isSuccess
          ? transaction.copyWith(
        status: PaymentStatus.completed,
        completedAt: DateTime.now(),
      )
          : transaction.copyWith(
        status: PaymentStatus.failed,
        failureReason: 'Payment declined by issuer',
      );

      // Add to mock data
      _paymentTransactions.add(updatedTransaction.toJson());

      return updatedTransaction;
    } catch (e) {
      throw Exception('Failed to process payment: ${e.toString()}');
    }
  }

  // Get payment transaction by ID
  Future<PaymentTransactionModel?> getTransactionById(String transactionId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay

    try {
      final transactionJson = _paymentTransactions.firstWhere(
            (transaction) => transaction['transactionId'] == transactionId,
        orElse: () => throw Exception('Transaction not found'),
      );

      return PaymentTransactionModel.fromJson(transactionJson);
    } catch (e) {
      throw Exception('Failed to get transaction: ${e.toString()}');
    }
  }

  Future<List<PaymentTransactionModel>> getTransactionsByOrderId(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    try {
      final transactions = _paymentTransactions
          .where((transaction) => transaction['orderId'] == orderId)
          .map((json) => PaymentTransactionModel.fromJson(json))
          .toList();

      return transactions;
    } catch (e) {
      throw Exception('Failed to get transactions: ${e.toString()}');
    }
  }

  // Refund payment
  Future<PaymentTransactionModel> refundPayment(String transactionId) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate refund processing delay

    try {
      // Find transaction
      final transactionIndex = _paymentTransactions.indexWhere(
            (transaction) => transaction['transactionId'] == transactionId,
      );

      if (transactionIndex < 0) {
        throw Exception('Transaction not found');
      }

      // Only completed payments can be refunded
      if (_paymentTransactions[transactionIndex]['status'] != 'completed') {
        throw Exception('Only completed payments can be refunded');
      }

      // Update transaction status
      _paymentTransactions[transactionIndex]['status'] = 'refunded';

      return PaymentTransactionModel.fromJson(_paymentTransactions[transactionIndex]);
    } catch (e) {
      throw Exception('Failed to refund payment: ${e.toString()}');
    }
  }
}
