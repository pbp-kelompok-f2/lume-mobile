import 'dart:convert';

class Product {
  final String id;
  final String name;
  final int price;
  final String description;
  final String thumbnail;
  final bool inStock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.thumbnail,
    required this.inStock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
      thumbnail: json['thumbnail_proxy'] ?? json['thumbnail'] ?? "",
      inStock: json['in_stock'],
    );
  }
}