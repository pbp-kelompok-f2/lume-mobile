class ProductItem {
  final String name;
  final String image;
  final int price;
  final int quantity;

  ProductItem({
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      name: json['name'] ?? "Unknown Product",
      image: json['image'] ?? "", 
      price: (json['price'] ?? 0).toInt(),
      quantity: (json['quantity'] ?? 1).toInt(),
    );
  }
}

class OrderHistory {
  final String id;
  final String date;
  final String status;
  final int totalAmount;
  final List<ProductItem> items;

  OrderHistory({
    required this.id,
    required this.date,
    required this.status,
    required this.totalAmount,
    required this.items,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    var listItems = json['items'] as List? ?? [];
    List<ProductItem> parsedItems = listItems.map((i) => ProductItem.fromJson(i)).toList();

    return OrderHistory(
      id: json['id']?.toString() ?? "0",
      date: json['date_ordered'] ?? "Unknown Date",
      status: json['status'] ?? "Completed",
      totalAmount: (json['total_amount'] ?? 0).toInt(),
      items: parsedItems,
    );
  }
}

class BookingHistory {
  final int id;
  final String className;
  final String instructor;
  final String time;
  final String day; 
  final String status;
  final int price;

  BookingHistory({
    required this.id,
    required this.className,
    required this.instructor,
    required this.time,
    required this.day,
    required this.status,
    required this.price,
  });

  factory BookingHistory.fromJson(Map<String, dynamic> json) {
    return BookingHistory(
      id: json['booking_id'] ?? 0,
      className: json['session_title'] ?? "Class",
      instructor: json['instructor'] ?? "Instructor",
      time: json['time'] ?? "Time",
      day: json['day'] ?? "Day",
      status: json['status'] ?? "Upcoming",
      price: (json['price'] is String) 
          ? double.parse(json['price']).toInt() 
          : (json['price'] ?? 0).toInt(),
    );
  }
}