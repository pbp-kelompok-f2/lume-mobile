import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/models/product.dart';
import 'package:lume_mobile/catalog/widgets/product_card.dart';
import 'package:lume_mobile/home/widgets/home_banner.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  // 1. Terima fungsi navigasi dari induk (MainScaffold)
  final Function(int) onNavigateTo; 

  const HomePage({super.key, required this.onNavigateTo});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "Myscha";

  // ... (kode fetchFeaturedProducts tetap sama) ...
  Future<List<Product>> fetchFeaturedProducts(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/catalog/api/products/?limit=5');
    var data = response;
    List<Product> listProduct = [];
    for (var d in data['results']) {
      if (d != null) { listProduct.add(Product.fromJson(d)); }
    }
    return listProduct;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ... (Header Hello User tetap sama) ...
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Hello, $username!", style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFFA3A89D))),
                        const SizedBox(height: 4),
                        Text("Welcome back to Lume.", style: GoogleFonts.inter(fontSize: 14, color: LumeColors.mutedText)),
                      ],
                    ),
                    const Icon(Icons.account_circle_outlined, size: 40, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 24),

                // 2. Panggil HomeBanner dan oper fungsi untuk ganti ke Tab Index 1 (Products)
                HomeBanner(
                  onShopNow: () {
                    widget.onNavigateTo(1); // Index 1 adalah tab "Products"
                  },
                ),

                // ... (Sisa kode ke bawah TETAP SAMA, tidak ada perubahan) ...
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFA3A89D),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Featured Products", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                  ),
                  child: SizedBox(
                    height: 340,
                    child: FutureBuilder(
                      future: fetchFeaturedProducts(request),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.data == null) {
                          return const Center(child: CircularProgressIndicator());
                        } else {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text("Belum ada produk featured.", style: TextStyle(color: Colors.grey)));
                          } else {
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 240,
                                  margin: const EdgeInsets.only(right: 16),
                                  child: ProductCard(product: snapshot.data![index]),
                                );
                              },
                            );
                          }
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 80), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}