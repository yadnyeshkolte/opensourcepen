// lib/views/checkout_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../view_models/cart_view_model.dart';
import '../view_models/order_view_model.dart';
import '../view_models/payment_view_model.dart';
import '../view_models/product_view_model.dart';
import 'payment_view.dart';
import 'order_confirmation_view.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  String _selectedShippingMethodId = '';
  bool _isAddressExpanded = false;
  bool _isShippingExpanded = true;
  bool _isPaymentExpanded = false;
  bool _isOrderSummaryExpanded = false;

  @override
  void initState() {
    super.initState();

    // Initialize checkout data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
      final paymentViewModel = Provider.of<PaymentViewModel>(context, listen: false);

      // Load shipping methods and address
      orderViewModel.loadShippingMethods();
      orderViewModel.loadShippingAddress();

      // Load payment methods
      paymentViewModel.loadPaymentMethods();
    });
  }

  void _continueToPayment() {
    // Validate that shipping method is selected
    if (_selectedShippingMethodId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a shipping method')),
      );
      return;
    }

    final paymentViewModel = Provider.of<PaymentViewModel>(context, listen: false);
    if (!paymentViewModel.hasPaymentMethods) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a payment method')),
      );
      return;
    }

    // Navigate to payment screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentView(
          shippingMethodId: _selectedShippingMethodId,
        ),
      ),
    );
  }

  void _placeOrder() async {
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
    final paymentViewModel = Provider.of<PaymentViewModel>(context, listen: false);
    final productViewModel = Provider.of<ProductViewModel>(context, listen: false);

    if (cartViewModel.cart == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    if (_selectedShippingMethodId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a shipping method')),
      );
      return;
    }

    if (paymentViewModel.selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing your order...'),
          ],
        ),
      ),
    );

    // Create order
    final order = await orderViewModel.createOrder(
      cart: cartViewModel.cart!,
      shippingMethodId: _selectedShippingMethodId,
      paymentMethodId: paymentViewModel.selectedPaymentMethod!.id,
      availableProducts: productViewModel.products,
    );

    // Close loading dialog
    Navigator.pop(context);

    if (order != null) {
      // Process payment
      final paymentResult = await paymentViewModel.processPayment(
        orderId: order.id,
        amount: order.total,
      );

      if (paymentResult) {
        // Clear cart after successful order
        await cartViewModel.clearCart();

        // Navigate to order confirmation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderConfirmationView(orderId: order.id),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(paymentViewModel.errorMessage)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orderViewModel.errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer3<CartViewModel, OrderViewModel, PaymentViewModel>(
        builder: (context, cartViewModel, orderViewModel, paymentViewModel, child) {
          if (cartViewModel.isLoading || orderViewModel.isLoading || paymentViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartViewModel.cart == null || cartViewModel.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shipping Address
                _buildSection(
                  title: 'Shipping Address',
                  isExpanded: _isAddressExpanded,
                  onToggle: () => setState(() => _isAddressExpanded = !_isAddressExpanded),
                  content: _buildShippingAddressContent(orderViewModel),
                ),
                const SizedBox(height: 16),

                // Shipping Method
                _buildSection(
                  title: 'Shipping Method',
                  isExpanded: _isShippingExpanded,
                  onToggle: () => setState(() => _isShippingExpanded = !_isShippingExpanded),
                  content: _buildShippingMethodContent(orderViewModel),
                ),
                const SizedBox(height: 16),

                // Payment Method
                _buildSection(
                  title: 'Payment Method',
                  isExpanded: _isPaymentExpanded,
                  onToggle: () => setState(() => _isPaymentExpanded = !_isPaymentExpanded),
                  content: _buildPaymentMethodContent(paymentViewModel),
                ),
                const SizedBox(height: 16),

                // Order Summary
                _buildSection(
                  title: 'Order Summary',
                  isExpanded: _isOrderSummaryExpanded,
                  onToggle: () => setState(() => _isOrderSummaryExpanded = !_isOrderSummaryExpanded),
                  content: _buildOrderSummaryContent(cartViewModel, orderViewModel),
                ),
                const SizedBox(height: 24),

                // Continue to Payment / Place Order Button
                ElevatedButton(
                  onPressed: _continueToPayment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('CONTINUE TO PAYMENT', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget content,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: onToggle,
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: content,
            ),
        ],
      ),
    );
  }

  Widget _buildShippingAddressContent(OrderViewModel orderViewModel) {
    final address = orderViewModel.shippingAddress;
    if (address == null) {
      return const Center(child: Text('Loading shipping address...'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${address.fullName}', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(address.addressLine1),
        if (address.addressLine2.isNotEmpty) Text(address.addressLine2),
        Text('${address.city}, ${address.state} ${address.postalCode}'),
        Text(address.country),
        Text(address.phoneNumber),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            // Navigate to edit address screen (not implemented in this prototype)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Edit address functionality will be implemented later')),
            );
          },
          child: const Text('Change Address'),
        ),
      ],
    );
  }

  Widget _buildShippingMethodContent(OrderViewModel orderViewModel) {
    if (orderViewModel.shippingMethods.isEmpty) {
      return const Center(child: Text('Loading shipping methods...'));
    }

    return Column(
      children: orderViewModel.shippingMethods.map((method) {
        final isSelected = _selectedShippingMethodId == method.id;
        return RadioListTile<String>(
          title: Text(method.name),
          subtitle: Text('${method.estimatedDelivery} - \$${method.price.toStringAsFixed(2)}'),
          value: method.id,
          groupValue: _selectedShippingMethodId,
          onChanged: (value) {
            setState(() {
              _selectedShippingMethodId = value!;
            });
          },
          activeColor: Theme.of(context).primaryColor,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildPaymentMethodContent(PaymentViewModel paymentViewModel) {
    if (paymentViewModel.paymentMethods.isEmpty) {
      return const Center(child: Text('Loading payment methods...'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...paymentViewModel.paymentMethods.map((method) {
          final isSelected = paymentViewModel.selectedPaymentMethod?.id == method.id;
          return ListTile(
            title: Text(method.name),
            subtitle: Text(method.type),
            leading: Icon(
              method.type == 'credit_card' ? Icons.credit_card : Icons.account_balance_wallet,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            ),
            trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
            onTap: () {
              paymentViewModel.selectPaymentMethod(method.id);
              setState(() {});
            },
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            // Navigate to add payment method screen (not implemented in this prototype)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add payment method functionality will be implemented later')),
            );
          },
          child: const Text('Add Payment Method'),
        ),
      ],
    );
  }

  Widget _buildOrderSummaryContent(CartViewModel cartViewModel, OrderViewModel orderViewModel) {
    final ShippingMethod? selectedShippingMethod = _selectedShippingMethodId.isNotEmpty
        ? orderViewModel.shippingMethods.firstWhere((method) => method.id == _selectedShippingMethodId)
        : null;

    final double shippingCost = selectedShippingMethod?.price ?? 0.0;
    final double subtotal = cartViewModel.subtotal;
    final double tax = cartViewModel.tax;
    final double total = subtotal + tax + shippingCost;

    return Column(
      children: [
        // Summary rows
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Subtotal'),
            Text('\$${subtotal.toStringAsFixed(2)}'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tax (8.5%)'),
            Text('\$${tax.toStringAsFixed(2)}'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Shipping (${selectedShippingMethod?.name ?? 'Not Selected'})'),
            Text('\$${shippingCost.toStringAsFixed(2)}'),
          ],
        ),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              '\$${total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'By placing your order, you agree to our Terms of Service and Privacy Policy.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}