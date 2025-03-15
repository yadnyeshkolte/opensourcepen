// lib/view_models/payment_view_model.dart
import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';

class PaymentViewModel extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  List<PaymentMethodModel> _paymentMethods = [];
  PaymentMethodModel? _selectedPaymentMethod;
  PaymentTransactionModel? _currentTransaction;
  bool _isLoading = false;
  String _errorMessage = '';

  List<PaymentMethodModel> get paymentMethods => _paymentMethods;
  PaymentMethodModel? get selectedPaymentMethod => _selectedPaymentMethod;
  PaymentTransactionModel? get currentTransaction => _currentTransaction;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasPaymentMethods => _paymentMethods.isNotEmpty;
  bool get isPaymentSuccessful => _currentTransaction?.status == PaymentStatus.completed;

  // Load payment methods
  Future<void> loadPaymentMethods() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _paymentMethods = await _paymentService.getPaymentMethods();

      // Select the default payment method if available
      _selectedPaymentMethod = _paymentMethods.firstWhere(
            (method) => method.isDefault,
        orElse: () => _paymentMethods.isNotEmpty ? _paymentMethods.first : null,
      );
    } catch (e) {
      _errorMessage = 'Failed to load payment methods: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set selected payment method
  void selectPaymentMethod(String paymentMethodId) {
    _selectedPaymentMethod = _paymentMethods.firstWhere(
          (method) => method.id == paymentMethodId,
      orElse: () => null,
    );
    notifyListeners();
  }

  // Process payment for order
  Future<bool> processPayment({required String orderId, required double amount}) async {
    if (_selectedPaymentMethod == null) {
      _errorMessage = 'No payment method selected';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _currentTransaction = await _paymentService.processPayment(
        orderId: orderId,
        amount: amount,
        paymentMethodId: _selectedPaymentMethod!.id,
      );

      return _currentTransaction?.status == PaymentStatus.completed;
    } catch (e) {
      _errorMessage = 'Payment failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get transaction by ID
  Future<void> getTransactionById(String transactionId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _currentTransaction = await _paymentService.getTransactionById(transactionId);
    } catch (e) {
      _errorMessage = 'Failed to get transaction: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<PaymentTransactionModel>> getTransactionsByOrderId(String orderId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final transactions = await _paymentService.getTransactionsByOrderId(orderId);
      return transactions;
    } catch (e) {
      _errorMessage = 'Failed to get transactions: ${e.toString()}';
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Request refund
  Future<bool> requestRefund(String transactionId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _currentTransaction = await _paymentService.refundPayment(transactionId);
      return _currentTransaction?.status == PaymentStatus.refunded;
    } catch (e) {
      _errorMessage = 'Refund failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}