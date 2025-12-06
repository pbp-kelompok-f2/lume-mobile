

class CartItem {
  int id;
  String productName;
  double price;
  String image;
  int quantity;
  String productId;
  bool isSelected; 

  CartItem({
    required this.id,
    required this.productName,
    required this.price,
    required this.image,
    required this.quantity,
    required this.productId,
    required this.isSelected, 
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productName: json['product_name'] ?? "Product Name",
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      image: json['thumbnail'] ?? "",
      quantity: json['quantity'] ?? 1,
      productId: json['product_id'] ?? "",
      isSelected: json['is_selected'] ?? true, 
    );
  }
}
