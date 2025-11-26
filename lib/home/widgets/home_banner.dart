import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeBanner extends StatelessWidget {
  // 1. Tambahkan callback function
  final VoidCallback onShopNow; 

  const HomeBanner({
    super.key, 
    required this.onShopNow, // 2. Wajib diisi saat dipanggil
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 320, 
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage('https://raw.githubusercontent.com/pbp-kelompok-f2/Lume/master/static/hero/hero-landing.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Stack(
        children: [
          // ... (Bagian Gradient sama seperti sebelumnya) ...
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.5)],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text("Find Your Flow\nwith Lume.",
                  style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, height: 1.2),
                ),
                const SizedBox(height: 12),
                Text("Feel stronger, move freely, and unwind with us. Join our Pilates family.",
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white.withOpacity(0.9), height: 1.4),
                ),
                const SizedBox(height: 24),
                
                // Buttons Row
                Row(
                  children: [
                    // Book Class Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text("Book a Class",
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF6E7D6B)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // --- BUTTON SHOP PRODUCTS (YANG DI-UPDATE) ---
                    InkWell(
                      onTap: onShopNow, // 3. Panggil callback saat ditekan
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text("Shop Products",
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}