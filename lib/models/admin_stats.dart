class AdminStats {
  final int totalUsers;
  final int totalOrders;
  final int totalBookings;
  final double totalIncome;

  AdminStats({
    required this.totalUsers,
    required this.totalOrders,
    required this.totalBookings,
    required this.totalIncome,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['total_users'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      totalBookings: json['total_bookings'] ?? 0,
      totalIncome: (json['total_income'] ?? 0).toDouble(),
    );
  }
}