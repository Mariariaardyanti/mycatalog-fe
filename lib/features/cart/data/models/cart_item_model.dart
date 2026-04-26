class CartItemModel {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final String category; 
  int quantity;

  CartItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.quantity = 1,
  });

  double get total => price * quantity;
}