
class OrderHistory {
  final int id;
  final String date;
  final String status;
  final int totalAmount;
  final List<String> items; 

  OrderHistory({
    required this.id,
    required this.date,
    required this.status,
    required this.totalAmount,
    required this.items,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
      id: json['id'] ?? 0,
      date: json['date_ordered'] ?? "Unknown Date", 
      status: json['status'] ?? "Pending",
      totalAmount: json['total_amount'] ?? 0,
      items: json['items_names'] != null 
          ? List<String>.from(json['items_names']) 
          : ["Items info not available"],
    );
  }
}

class BookingHistory {
  final int id;
  final String className;
  final String instructor;
  final String date;
  final String time;
  final String status;

  BookingHistory({
    required this.id,
    required this.className,
    required this.instructor,
    required this.date,
    required this.time,
    required this.status,
  });

  factory BookingHistory.fromJson(Map<String, dynamic> json) {

    final classSession = json['class_session_details'] ?? {}; 
    return BookingHistory(
      id: json['id'] ?? 0,
      className: classSession['title'] ?? json['class_name'] ?? "Class",
      instructor: classSession['instructor'] ?? "Instructor",
      date: classSession['date'] ?? json['booking_date'] ?? "Date",
      time: classSession['time'] ?? "Time",
      status: json['status'] ?? "Upcoming",
    );
  }
}