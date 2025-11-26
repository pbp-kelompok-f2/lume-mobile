import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/models/product.dart';
import 'package:lume_mobile/catalog/widgets/product_card.dart';
import 'package:lume_mobile/home/widgets/home_banner.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Nanti variabel ini diisi dari Provider/CookieRequest saat login
  String username = "Myscha";

  // Dummy Data
  final List<Product> _featuredProducts = [
    Product(
      id: "1",
      name: "Matras",
      price: 400000,
      description: "Premium Mat",
      thumbnail: "https://picsum.photos/200/300",
      inStock: true,
    ),
    Product(
      id: "4",
      name: "Bottle",
      price: 250000,
      description: "Water Bottle",
      thumbnail: "https://picsum.photos/203/300",
      inStock: true,
    ),
    Product(
      id: "2",
      name: "Yoga Block",
      price: 150000,
      description: "Support Block",
      thumbnail: "https://picsum.photos/201/300",
      inStock: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Contoh cara ambil user nanti kalau sudah integrasi PBP Django Auth:
    // final request = context.watch<CookieRequest>();
    // if (request.jsonData['username'] != null) {
    //    username = request.jsonData['username'];
    // }

    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header: Dynamic Hello User ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello, $username!", // <-- Sudah Dinamis (pake variabel)
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFA3A89D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Welcome back to Lume.",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: LumeColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.account_circle_outlined,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- Hero Banner ---
                const HomeBanner(),

                const SizedBox(height: 32),

                // --- Section: Featured Products Header ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFA3A89D),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Featured Products",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),

                // --- Section: Featured Products List ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 340,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _featuredProducts.length,
                      itemBuilder: (context, index) {
                        return Container(
                          // UBAH DISINI: Naikkan jadi 240 biar muat lega
                          width: 240,
                          margin: const EdgeInsets.only(right: 16),
                          child: ProductCard(product: _featuredProducts[index]),
                        );
                      },
                    ),
                  ),
                ),

                // --- (Upcoming Classes Placeholder) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFA3A89D),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Upcoming Classes",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  // Nanti diisi list class
                ),

                const SizedBox(
                  height: 80,
                ), // Space bawah biar ga ketutup navbar temen lu
              ],
            ),
          ),
        ),
      ),
    );
  }
}
