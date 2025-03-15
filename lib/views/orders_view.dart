import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/order_view_model.dart';
import 'package:intl/intl.dart'; // Add this package to pubspec.yaml

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final orderViewModel = Provider.of<OrderViewModel>(context);

    // Load orders when the view is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (orderViewModel.orders.isEmpty) {
        orderViewModel.fetchOrders();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: orderViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderViewModel.errorMessage.isNotEmpty
          ? Center(child: Text(orderViewModel.errorMessage))
          : orderViewModel.isEmpty
          ? const Center(child: Text('No Recent Orders'))
          : ListView.builder(
        itemCount: orderViewModel.orders.length,
        itemBuilder: (context, index) {
          final order = orderViewModel.orders[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ExpansionTile(
              title: Text('Order #${order.id}'),
              subtitle: Text(
                'Date: ${DateFormat('MMM dd, yyyy').format(order.orderDate)} • '
                    'Status: ${order.status.toUpperCase()}',
              ),
              trailing: Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: order.items.length,
                  itemBuilder: (context, itemIndex) {
                    final item = order.items[itemIndex];
                    return ListTile(
                      dense: true,
                      title: Text(item.name),
                      subtitle: Text(
                        'Qty: ${item.quantity} x \$${item.price.toStringAsFixed(2)}',
                      ),
                      trailing: Text(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Placeholder for reordering functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reorder functionality will be added soon'),
                        ),
                      );
                    },
                    child: const Text('REORDER'),
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