

class Product {
  final String id;
  final String name;
  final int price;
  final String description;
  final String thumbnail;
  final String thumbnailProxy;
  final bool inStock;
  final int stock;
  final bool isWishlisted;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.thumbnail,
    required this.thumbnailProxy,
    required this.inStock,
    required this.stock, 
    this.isWishlisted = false,
  });

  String get displayThumbnail {
    return thumbnailProxy.isNotEmpty ? thumbnailProxy : thumbnail;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
      thumbnail: json['thumbnail'] ?? "",
      thumbnailProxy: json['thumbnail_proxy'] ?? "",
      inStock: json['in_stock'],
      stock: json['stock'] ?? 0, 
      isWishlisted: json['is_wishlisted'] ?? json['in_wishlist'] ?? false,
    );
  }
}
