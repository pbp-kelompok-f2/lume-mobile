import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderConfirmedDialog extends StatelessWidget {
  final VoidCallback onBackToHome;
  final VoidCallback onViewOrderHistory;

  const OrderConfirmedDialog({
    super.key,
    required this.onBackToHome,
    required this.onViewOrderHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFD9D9D2), Color(0xFFB8B8AE)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  size: 50,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                "Order Confirmed!",
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3E4038),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                "Thank you for your purchase!\nYour order has been placed successfully.",
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.4,
                  color: const Color(0xFF7A7C72),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12, 
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width < 350 ? double.infinity : null,
                    child: ElevatedButton(
                      onPressed: onViewOrderHistory,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: const Color(0xFFB8B8AE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "View Order History",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: MediaQuery.of(context).size.width < 350 ? double.infinity : null,
                    child: OutlinedButton(
                      onPressed: onBackToHome,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        side: const BorderSide(color: Color(0xFFC8C9BD)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Back to Home",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF7A7C72),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}