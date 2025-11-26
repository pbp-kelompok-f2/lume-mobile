import 'dart:convert';

class CartItem {
  int id;
  String productName;
  double price;
  String image; // URL gambar produk
  int quantity;
  int productId;

  CartItem({
    required this.id,
    required this.productName,
    required this.price,
    required this.image,
    required this.quantity,
    required this.productId,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Sesuaikan field ini dengan respon JSON dari view Django Anda
    // Biasanya Django mereturn object Product nested atau flat
    return CartItem(
      id: json['id'], 
      productName: json['product__name'] ?? "Product Name", // Sesuaikan key JSON
      price: double.tryParse(json['product__price'].toString()) ?? 0.0,
      image: json['product__image'] ?? "", // Pastikan backend kirim URL
      quantity: json['quantity'],
      productId: json['product'],
    );
  }
}