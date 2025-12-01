import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; 
import 'package:lume_mobile/auth/screens/login_page.dart';
import 'package:lume_mobile/main/screens/main_scaffold.dart';
import 'package:lume_mobile/models/profile.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  Future<List<OrderHistory>> fetchOrderHistory(CookieRequest request) async {
    final response = await request.get('http://localhost:8000/checkout/json/');
    List<OrderHistory> listOrder = [];
    for (var d in response) {
      if (d != null) listOrder.add(OrderHistory.fromJson(d));
    }
    return listOrder;
  }

  Future<List<BookingHistory>> fetchBookingHistory(CookieRequest request) async {
    final response = await request.get('http://localhost:8000/bookingkelas/json/');
    List<BookingHistory> listBooking = [];
    for (var d in response) {
      if (d != null) listBooking.add(BookingHistory.fromJson(d));
    }
    return listBooking;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    if (!request.loggedIn) {
      return const LoginPage();
    }

    String username = request.jsonData['username'] ?? "User"; 

    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      appBar: AppBar(
        backgroundColor: LumeColors.creamBackground,
        elevation: 0,
        title: Text("Profile", style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFFA8AF9F))),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(username),
            const SizedBox(height: 20),

            FutureBuilder(
              future: fetchOrderHistory(request),
              builder: (context, AsyncSnapshot<List<OrderHistory>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                   return const Center(child: CircularProgressIndicator());
                }
                return _buildSectionCard(
                  title: "Purchase History",
                  icon: Icons.shopping_bag_outlined,
                  children: (!snapshot.hasData || snapshot.data!.isEmpty)
                      ? [const Padding(padding: EdgeInsets.all(12), child: Text("No orders yet."))]
                      : snapshot.data!.map((order) => _buildOrderRow(order)).toList(),
                );
              },
            ),
            const SizedBox(height: 20),

            FutureBuilder(
              future: fetchBookingHistory(request),
              builder: (context, AsyncSnapshot<List<BookingHistory>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                   return const Center(child: CircularProgressIndicator());
                }
                return _buildSectionCard(
                  title: "Classes Booking History",
                  icon: Icons.self_improvement,
                  children: (!snapshot.hasData || snapshot.data!.isEmpty)
                      ? [const Padding(padding: EdgeInsets.all(12), child: Text("No bookings yet."))]
                      : snapshot.data!.map((booking) => _buildBookingRow(booking)).toList(),
                );
              },
            ),
            const SizedBox(height: 40),

SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  final response = await request.logout("http://localhost:8000/user/logout/");
                  if (response['status']) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Successfully logged out!")));
                      
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MainScaffold(initialIndex: 0)),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB0B5A9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), elevation: 0),
                child: Text("Log Out", style: GoogleFonts.inter(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String username) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF8E9388),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              color: Colors.grey.shade300,
            ),
            child: const Icon(Icons.person, size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text("Edit Profile", style: GoogleFonts.inter(color: Colors.white, fontSize: 12)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.white),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: LumeColors.darkText),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: LumeColors.darkText)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade400, width: 0.5)),
            ),
            child: Column(children: children),
          )
        ],
      ),
    );
  }

  Widget _buildOrderRow(OrderHistory order) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(order.date, style: GoogleFonts.inter(fontSize: 12, color: LumeColors.mutedText)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.items.join(", "), style: GoogleFonts.inter(fontSize: 13, color: LumeColors.darkText)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(currencyFormatter.format(order.totalAmount), style: GoogleFonts.inter(fontSize: 13, color: LumeColors.darkText)),
              const SizedBox(height: 4),
              _buildStatusBadge(order.status),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBookingRow(BookingHistory booking) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(booking.className, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                _buildStatusBadge(booking.status),
              ],
            ),
            const SizedBox(height: 4),
            Text("Instructor: ${booking.instructor}", style: GoogleFonts.inter(fontSize: 11, color: LumeColors.mutedText)),
            Text("📅 ${booking.date}", style: GoogleFonts.inter(fontSize: 11, color: LumeColors.mutedText)),
            Text("🕒 ${booking.time}", style: GoogleFonts.inter(fontSize: 11, color: LumeColors.mutedText)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isCompleted = status.toLowerCase() == "completed" || status.toLowerCase() == "success";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFD4E2D4) : const Color(0xFFD0DCE6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCompleted ? const Color(0xFFA8C3A8) : const Color(0xFFA8BCC3)),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(fontSize: 10, color: isCompleted ? const Color(0xFF5F7A5F) : const Color(0xFF5F707A)),
      ),
    );
  }
}