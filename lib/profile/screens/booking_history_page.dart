import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lume_mobile/models/profile.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/widgets/lume_app_bar.dart';
import 'package:lume_mobile/config/api_config.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

Future<List<BookingHistory>> fetchBookingHistory(CookieRequest request) async {
  final response = await request.get(apiPath('/bookingkelas/my-bookings/'));
  List<BookingHistory> listBooking = [];
  
  if (response is Map && response.containsKey('bookings')) {
    for (var d in response['bookings']) {
      if (d != null) {
        final booking = BookingHistory.fromJson(d);
        String status = booking.status.toLowerCase();
        if (status != 'pending payment' && status != 'pending') {
          listBooking.add(booking);
        }
      }
    }
  }
  return listBooking;
}

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      appBar: const LumeAppBar(title: "Class Bookings"),
      body: FutureBuilder(
        future: fetchBookingHistory(request),
        builder: (context, AsyncSnapshot<List<BookingHistory>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: LumeColors.sageGreen));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    "No class bookings yet.",
                    style: GoogleFonts.inter(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildBookingCard(snapshot.data![index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(BookingHistory booking) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 237, 233, 222),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === HEADER: Day & Status ===
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EBE0), // Light Sage accent
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.self_improvement, 
                          size: 18, color: LumeColors.sageGreen),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Day",
                          style: GoogleFonts.inter(
                            fontSize: 10, 
                            color: Colors.grey.shade500
                          ),
                        ),
                        Text(
                          booking.day,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: LumeColors.darkText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildStatusBadge(booking.status),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, thickness: 0.5),
            ),

            // === BODY: Class Details ===
            Text(
              booking.className,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: LumeColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  booking.instructor,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade700),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  booking.time,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // === FOOTER: Price ===
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Price",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  currencyFormatter.format(booking.price),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: LumeColors.sageGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'success':
        bgColor = const Color(0xFFE3F5E3); 
        textColor = const Color(0xFF2E7D32);
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
