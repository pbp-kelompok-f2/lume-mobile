import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/widgets/lume_app_bar.dart';
import 'package:lume_mobile/config/api_config.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lume_mobile/main/screens/main_scaffold.dart';

class BookingCheckoutPage extends StatefulWidget {
  final int bookingId;

  const BookingCheckoutPage({super.key, required this.bookingId});

  @override
  State<BookingCheckoutPage> createState() => _BookingCheckoutPageState();
}

class _BookingCheckoutPageState extends State<BookingCheckoutPage> {
  bool isLoading = true;
  bool isProcessing = false; // ✅ Loading state untuk button
  Map<String, dynamic>? bookingData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // ✅ Pake WidgetsBinding biar bisa akses Provider di initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDetails();
    });
  }

  // ✅ Helper: Convert day code '0'-'6' ke nama hari
  String _getDayName(String dayCode) {
    const map = {
      '0': 'Monday',
      '1': 'Tuesday',
      '2': 'Wednesday',
      '3': 'Thursday',
      '4': 'Friday',
      '5': 'Saturday',
      '6': 'Sunday',
    };
    return map[dayCode] ?? dayCode; // Fallback ke input asli jika bukan '0'-'6'
  }

  // ✅ Helper: Format harga jadi Rp 100.000
  String _formatPrice(dynamic price) {
    String priceStr = price.toString();
    return "Rp ${priceStr.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.',
    )}";
  }

  // Ambil detail harga dari API Django
  Future<void> fetchDetails() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        apiPath('/checkout/api/booking-details/${widget.bookingId}/'),
      );

      if (response['status'] == 'success') {
        setState(() {
          bookingData = response['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Failed to load booking details';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  // Proses pembayaran
  Future<void> handlePayment() async {
    if (isProcessing) return; // ✅ Prevent double tap

    setState(() => isProcessing = true);

    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        apiPath('/checkout/api/process-payment/'),
        jsonEncode({'booking_id': widget.bookingId}),
      );

      if (mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Payment Successful! 🎉",
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFF6E7D6B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          // ✅ Redirect ke Profile Page (Tab Index 3)
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainScaffold(initialIndex: 3),
            ),
            (route) => false,
          );
        } else {
          setState(() => isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Payment failed'),
              backgroundColor: Colors.red[400],
            ),
          );
        }
      }
    } catch (e) {
      setState(() => isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      appBar: const LumeAppBar(title: "Checkout"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorState()
              : _buildCheckoutContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6E7D6B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Go Back",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutContent() {
    // ✅ Convert day code ke nama hari yang readable
    final dayDisplay = _getDayName(bookingData!['day']);
    final priceFormatted = _formatPrice(bookingData!['total_payment']);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // --- SUMMARY CARD ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E0D8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1ECE2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Color(0xFF6E7D6B),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Order Summary",
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2C3028),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                _infoRow("Class", bookingData!['title']),
                _infoRow("Instructor", bookingData!['instructor']),
                _infoRow("Schedule", "$dayDisplay, ${bookingData!['time']}"),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Color(0xFFE5E0D8)),
                ),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Payment",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3028),
                      ),
                    ),
                    Text(
                      priceFormatted,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF6E7D6B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ✅ Payment Method Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE5A3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFFD4A017),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Payment Method: Cash on Arrival",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8B6F00),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // --- PAY BUTTON ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isProcessing ? null : handlePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6E7D6B),
                disabledBackgroundColor: Colors.grey[400],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                shadowColor: Colors.black.withOpacity(0.2),
              ),
              child: isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Confirm Payment",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: const Color(0xFF2C3028),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
