// lib/views/payment_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/cart_view_model.dart';
import '../view_models/order_view_model.dart';
import '../view_models/payment_view_model.dart';
import '../view_models/product_view_model.dart';
import 'order_confirmation_view.dart';

class PaymentView extends StatefulWidget {
  final String shippingMethodId;

  const PaymentView({super.key, required this.shippingMethodId});

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Make sure payment methods are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final paymentViewModel = Provider.of<PaymentViewModel>(context, listen: false);
      if (paymentViewModel.paymentMethods.isEmpty) {
        paymentViewModel.loadPaymentMethods();
      }
    });
  }

  void _processPayment() async {
    setState(() => _isProcessing = true);

    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    final orderViewModel = Provider.of<OrderViewModel>(context, listen: false);
    final paymentViewModel = Provider.of<PaymentViewModel>(context, listen: false);
    final productViewModel = Provider.of<ProductViewModel>(context, listen: false);

    if (cartViewModel.cart == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      setState(() => _isProcessing = false);
      return;
    }

    if (paymentViewModel.selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      setState(() => _isProcessing = false);
      return;
    }

    try {
      // Create order
      final order = await orderViewModel.createOrder(
        cart: cartViewModel.cart!,
        shippingMethodId: widget.shippingMethodId,
        paymentMethodId: paymentViewModel.selectedPaymentMethod!.id,
        availableProducts: productViewModel.products,
      );

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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
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

          // Calculate total with shipping
          final selectedShippingMethod = orderViewModel.shippingMethods.firstWhere(
                (method) => method.id == widget.shippingMethodId,
            orElse: () => ShippingMethod(
              id: '',
              name: 'Unknown',
              price: 0,
              estimatedDelivery: '',
            ),
          );

          final double subtotal = cartViewModel.subtotal;
          final double tax = cartViewModel.tax;
          final double shippingCost = selectedShippingMethod.price;
          final double total = subtotal + tax + shippingCost;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment method selection
                const Text(
                  'Select Payment Method',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                if (paymentViewModel.paymentMethods.isEmpty)
                  const Center(child: Text('No payment methods available'))
                else
                  Card(
                    child: Column(
                      children: paymentViewModel.paymentMethods.map((method) {
                        final isSelected = paymentViewModel.selectedPaymentMethod?.id == method.id;
                        return ListTile(
                          title: Text(method.name),
                          subtitle: Text(method.type),
                          leading: Icon(
                            method.type == 'credit_card' ? Icons.credit_card : Icons.account_balance_wallet,
                            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                          ),
                          trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).primaryColor) : null,
                          selected: isSelected,
                          onTap: () {
                            paymentViewModel.selectPaymentMethod(method.id);
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                  ),

                const SizedBox(height: 24),

                // Order summary
                const Text(
                  'Order Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Items summary
                        Text('${cartViewModel.itemCount} item(s) in cart'),
                        const Divider(height: 24),

                        // Pricing details
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
                            Text('Shipping (${selectedShippingMethod.name})'),
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
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Payment button
                ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('COMPLETE PURCHASE', style: TextStyle(fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Your payment information is secure',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}