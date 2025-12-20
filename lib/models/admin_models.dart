class AdminUser {
  final int id;
  final String username;
  final String email;
  final String phone;
  final String joinDate;
  final int totalOrders;
  final int totalBookings;
  final String status;

  AdminUser({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.joinDate,
    required this.totalOrders,
    required this.totalBookings,
    required this.status,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      username: json['username'] ?? "-",
      email: json['email'] ?? "-",
      phone: json['phone'] ?? "-",
      joinDate: json['join_date'] ?? "-",
      totalOrders: json['total_orders'] ?? 0,
      totalBookings: json['total_bookings'] ?? 0,
      status: json['status'] ?? "active",
    );
  }
}

class AdminOrder {
  final String id;
  final String userName;
  final int amount;
  final String status;
  final String date;
  final List<AdminLineItem> items;

  AdminOrder({
    required this.id,
    required this.userName,
    required this.amount,
    required this.status,
    required this.date,
    required this.items,
  });

  factory AdminOrder.fromJson(Map<String, dynamic> json) {
    var list = json['line_items'] as List? ?? [];
    List<AdminLineItem> itemsList = list.map((i) => AdminLineItem.fromJson(i)).toList();

    return AdminOrder(
      id: json['id'],
      userName: json['user_name'] ?? "Unknown",
      amount: (json['amount'] ?? 0).toInt(),
      status: json['status'] ?? "Pending",
      date: json['date'] ?? "-",
      items: itemsList,
    );
  }
}

class AdminLineItem {
  final String name;
  final int qty;
  final int price;

  AdminLineItem({required this.name, required this.qty, required this.price});

  factory AdminLineItem.fromJson(Map<String, dynamic> json) {
    return AdminLineItem(
      name: json['name'] ?? "-",
      qty: (json['qty'] ?? 0).toInt(),
      price: (json['price'] ?? 0).toInt(),
    );
  }
}

class AdminBooking {
  final int id;
  final String userName;
  final String className;
  final String instructor;
  final String date;
  final String time;
  final String status;

  AdminBooking({
    required this.id,
    required this.userName,
    required this.className,
    required this.instructor,
    required this.date,
    required this.time,
    required this.status,
  });

  factory AdminBooking.fromJson(Map<String, dynamic> json) {
    return AdminBooking(
      id: json['id'],
      userName: json['user_name'] ?? "-",
      className: json['class_name'] ?? "-",
      instructor: json['instructor'] ?? "-",
      date: json['date'] ?? "-",
      time: json['time'] ?? "-",
      status: json['status'] ?? "-",
    );
  }
}