import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/order_view_model.dart';
import 'package:intl/intl.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final orderViewModel = Provider.of<OrderViewModel>(context);
    final Color skyBlue = const Color(0xFF87CEEB);
    final Color deepSkyBlue = const Color(0xFF00BFFF);
    final Color cornflowerBlue = const Color(0xFF6495ED);

    // Load orders when the view is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (orderViewModel.orders.isEmpty) {
        orderViewModel.fetchOrders();
      }
    });

    // Helper function to get status color
    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'delivered':
          return Colors.green;
        case 'processing':
          return cornflowerBlue;
        case 'shipped':
          return deepSkyBlue;
        case 'pending':
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: deepSkyBlue,
        centerTitle: true,
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: orderViewModel.isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: deepSkyBlue,
        ),
      )
          : orderViewModel.errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Orders',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              orderViewModel.errorMessage,
              style: TextStyle(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : orderViewModel.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: skyBlue,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Orders Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your order history will appear here',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orderViewModel.orders.length,
        itemBuilder: (context, index) {
          final order = orderViewModel.orders[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                colorScheme: ColorScheme.light(
                  primary: deepSkyBlue,
                ),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                childrenPadding: EdgeInsets.zero,
                title: Row(
                  children: [
                    Text(
                      'Order #${order.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: getStatusColor(order.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        order.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: getStatusColor(order.status),
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(order.orderDate),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
                trailing: Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: deepSkyBlue,
                  ),
                ),
                children: [
                  const Divider(height: 1, thickness: 1, indent: 20, endIndent: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.items.length,
                    itemBuilder: (context, itemIndex) {
                      final item = order.items[itemIndex];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          children: [
                            // Item image placeholder
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: skyBlue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.shopping_bag_outlined,
                                  color: skyBlue,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Item details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Qty: ${item.quantity} × \$${item.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Item total
                            Text(
                              '\$${item.totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cornflowerBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: deepSkyBlue,
                            content: const Text('Reorder functionality will be added soon'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'REORDER',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}