import 'dart:convert';

class CartItem {
  int id;
  String productName;
  double price;
  String image; // Menyimpan URL thumbnail
  int quantity;
  String productId; // ID produk biasanya string (UUID) di Django kamu

  CartItem({
    required this.id,
    required this.productName,
    required this.price,
    required this.image,
    required this.quantity,
    required this.productId,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      // Sesuaikan key dengan output cart/api.py
      productName: json['product_name'] ?? "Product Name",
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      image: json['thumbnail'] ?? "", // Di API namanya 'thumbnail'
      quantity: json['quantity'] ?? 1,
      productId: json['product_id'] ?? "", // Di API namanya 'product_id'
    );
  }
}