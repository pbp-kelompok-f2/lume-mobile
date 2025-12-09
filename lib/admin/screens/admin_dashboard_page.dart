import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/main/screens/main_scaffold.dart';
import 'package:lume_mobile/models/admin_stats.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lume_mobile/admin/screens/admin_user_list.dart';
import 'package:lume_mobile/admin/screens/admin_order_list.dart';
import 'package:lume_mobile/admin/screens/admin_booking_list.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final String baseUrl = "http://localhost:8000";

  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  Future<AdminStats?> fetchAdminStats(CookieRequest request) async {
    try {
      final response = await request.get(
        '$baseUrl/useradmin/api/dashboard-stats/',
      );
      return AdminStats.fromJson(response);
    } catch (e) {
      debugPrint("Error fetching admin stats: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    double screenWidth = MediaQuery.of(context).size.width;

    int gridCrossAxisCount = screenWidth > 700 ? 4 : 2;

    double childAspectRatio = screenWidth > 700 ? 1.5 : 1.3;

    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      appBar: AppBar(
        backgroundColor: LumeColors.creamBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            "Admin Dashboard",
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: LumeColors.darkText,
            ),
          ),
        ),
      ),
      body: FutureBuilder<AdminStats?>(
        future: fetchAdminStats(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: LumeColors.sageGreen),
            );
          }

          final stats = snapshot.data;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Overview",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: gridCrossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: childAspectRatio,
                      children: [
                        _buildStatCard(
                          "Total Income",
                          currencyFormatter.format(stats?.totalIncome ?? 0),
                          Icons.monetization_on,
                          const Color(0xFF6E7D6B),
                        ),
                        _buildStatCard(
                          "Total Users",
                          "${stats?.totalUsers ?? 0}",
                          Icons.group,
                          const Color(0xFF6E7D6B),
                        ),
                        _buildStatCard(
                          "Total Orders",
                          "${stats?.totalOrders ?? 0}",
                          Icons.shopping_bag,
                          const Color(0xFF6E7D6B),
                        ),
                        _buildStatCard(
                          "Total Bookings",
                          "${stats?.totalBookings ?? 0}",
                          Icons.calendar_today,
                          const Color(0xFF6E7D6B),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),
                    Text(
                      "Management",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildMenuButton(
                      context,
                      "View All Users",
                      Icons.person_search,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminUserListPage(),
                          ),
                        );
                      },
                    ),
                    _buildMenuButton(
                      context,
                      "View All Orders",
                      Icons.receipt_long,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminOrderListPage(),
                          ),
                        );
                      },
                    ),
                    _buildMenuButton(
                      context,
                      "View All Bookings",
                      Icons.event_note,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminBookingListPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // === TOMBOL LOGOUT (PINDAH KE BAWAH) ===
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          final response = await request.logout(
                            "$baseUrl/user/api/logout/",
                          );

                          if (response['ok'] == true) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Successfully logged out!"),
                                ),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MainScaffold(initialIndex: 0),
                                ),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Logout failed.")),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB0B5A9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Log Out",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // Pindahkan shadow ke sini agar tetap terlihat
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05), 
            blurRadius: 5, 
            offset: const Offset(0, 2)
          )
        ],
      ),
      // Gunakan Material untuk memotong (clip) efek hover
      child: Material(
        color: const Color.fromARGB(255, 237, 233, 222), // Warna background pindah ke Material
        borderRadius: BorderRadius.circular(16), // Tentukan sudut tumpul di sini
        child: InkWell( // Gunakan InkWell atau ListTile dengan shape
          borderRadius: BorderRadius.circular(16), // PENTING: Agar hover mengikuti sudut
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Padding manual karena kita ganti ListTile
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 237, 233, 222),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: LumeColors.darkText),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16, 
                      fontWeight: FontWeight.w600, 
                      color: LumeColors.darkText
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
