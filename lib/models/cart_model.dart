class CartItemModel {
  final String productId;
  final String name;
  final double price;
  final int quantity;

  CartItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  double get totalPrice => price * quantity;
}