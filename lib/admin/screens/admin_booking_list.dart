import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/models/admin_models.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AdminBookingListPage extends StatefulWidget {
  const AdminBookingListPage({super.key});

  @override
  State<AdminBookingListPage> createState() => _AdminBookingListPageState();
}

class _AdminBookingListPageState extends State<AdminBookingListPage> {
  final String baseUrl = "http://localhost:8000"; // Sesuaikan IP

  Future<List<AdminBooking>> fetchBookings(CookieRequest request) async {
    final response = await request.get('$baseUrl/useradmin/api/bookings/');
    List<AdminBooking> list = [];
    if (response['ok'] == true) {
      for (var d in response['bookings']) {
        list.add(AdminBooking.fromJson(d));
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      appBar: AppBar(
        backgroundColor: LumeColors.creamBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: LumeColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("All Bookings", style: GoogleFonts.inter(color: LumeColors.darkText, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder(
        future: fetchBookings(request),
        builder: (context, AsyncSnapshot<List<AdminBooking>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: LumeColors.sageGreen));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No bookings found."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final booking = snapshot.data![index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 237, 233, 222),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(booking.className, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: booking.status == 'active' ? const Color(0xFFE3F5E3) : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(8),
                          ),
  
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.person, "User", booking.userName),
                    const SizedBox(height: 4),
                    _buildInfoRow(Icons.sports_gymnastics, "Instructor", booking.instructor),
                    const SizedBox(height: 4),
                    _buildInfoRow(Icons.calendar_today, "Date", "${booking.date}, ${booking.time}"),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 8),
        Text("$label: ", style: GoogleFonts.inter(color: Colors.grey, fontSize: 13)),
        Text(value, style: GoogleFonts.inter(color: LumeColors.darkText, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}