import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/booking_kelas/widgets/class_card.dart'; // Import Widget ClassCard
import 'package:lume_mobile/models/booking_kelas.dart'; // Import Model ClassSession
import 'package:lume_mobile/models/product.dart';
import 'package:lume_mobile/catalog/widgets/product_card.dart';
import 'package:lume_mobile/home/widgets/home_banner.dart';
import 'package:lume_mobile/providers/user_provider.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lume_mobile/cart/screens/cart.dart';
import 'package:lume_mobile/providers/cart_provider.dart';

class HomePage extends StatefulWidget {
  // Terima fungsi navigasi dari induk (MainScaffold)
  final Function(int) onNavigateTo;

  const HomePage({super.key, required this.onNavigateTo});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Helper: Mapping angka string '0'-'6' ke Nama Hari (Untuk ClassCard)
  String _getDayName(String dayCode) {
    const map = {
      '0': 'Monday', '1': 'Tuesday', '2': 'Wednesday', 
      '3': 'Thursday', '4': 'Friday', '5': 'Saturday', '6': 'Sunday'
    };
    return map[dayCode] ?? dayCode; 
  }

  // Helper: Membersihkan judul
  String _baseTitle(String title) {
    int lastIndex = title.lastIndexOf(' - ');
    if (lastIndex != -1) {
      return title.substring(0, lastIndex);
    }
    return title;
  }

  // 1. FETCH FEATURED PRODUCTS
  Future<List<Product>> fetchFeaturedProducts(CookieRequest request) async {
    // Sesuaikan URL (10.0.2.2 untuk Android Emulator)
    final response = await request.get('http://localhost:8000/catalog/api/products/?limit=5');
    var data = response;
    List<Product> listProduct = [];
    if (data['results'] != null) {
      for (var d in data['results']) {
        if (d != null) {
          listProduct.add(Product.fromJson(d));
        }
      }
    }
    return listProduct;
  }

  // 2. FETCH POPULAR CLASSES (Baru)
  // Karena API khusus "popular" (sort by booking) belum ada JSON-nya,
  // kita ambil list kelas biasa dan tampilkan 6 pertama sebagai highlights.
  Future<List<ClassSession>> fetchPopularClasses(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/bookingkelas/json/');
    
    List<ClassSession> allSessions = [];
    // Handle format JSON dari Django
    var rawData = response;
    if (response is Map && response['sessions'] != null) {
      rawData = response['sessions'];
    }

    if (rawData is List) {
      for (var d in rawData) {
        if (d != null) allSessions.add(ClassSession.fromJson(d));
      }
    }

    // Ambil 6 kelas pertama saja (slicing) sesuai logika landing page
    if (allSessions.length > 6) {
      return allSessions.sublist(0, 6);
    }
    return allSessions;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final userProvider = context.watch<UserProvider>();
    final String username = userProvider.username;

    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === HEADER HELLO USER + CART ICON ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello, $username!",
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

                    // CART ICON
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartPage(),
                          ),
                        ).then((_) {
                          if (context.mounted) {
                            context
                                .read<CartProvider>()
                                .fetchCartCount(context.read<CookieRequest>());
                          }
                        });
                      },
                      child: Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          Widget cartIcon = Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Icon(
                              Icons.shopping_cart_outlined,
                              color: LumeColors.darkText,
                            ),
                          );

                          if (!request.loggedIn || cartProvider.counter <= 0) {
                            return cartIcon;
                          }

                          return Badge(
                            label: Text(
                              '${cartProvider.counter}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: LumeColors.darkGreen,
                            child: cartIcon,
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // === HOME BANNER ===
                HomeBanner(
                  onShopNow: () {
                    widget.onNavigateTo(1); // Pindah ke Tab Products (Index 1)
                  },
                  onBookClass: () {
                    widget.onNavigateTo(2); // Pindah ke Tab Classes (Index 2)
                  },
                ),

                const SizedBox(height: 32),

                // === FEATURED PRODUCTS SECTION ===
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                      )
                    ],
                  ),
                  child: SizedBox(
                    height: 340,
                    child: FutureBuilder(
                      future: fetchFeaturedProducts(request),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text("Belum ada produk featured.",
                                style: TextStyle(color: Colors.grey)),
                          );
                        } else {
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: 240,
                                margin: const EdgeInsets.only(right: 16),
                                child: AppProductCard(
                                  product: snapshot.data![index],
                                  // Kosongkan callback animasi jika tidak dipakai
                                  runAnimation: (_) {}, 
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // === MOST POPULAR CLASSES SECTION (NEW) ===
                // Tampilan disesuaikan dengan landing.html
                Center(
                  child: Text(
                    "Most Popular Classes",
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF6E7D6B), // Warna Hijau Lume text-[#6E7D6B]
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),

                FutureBuilder<List<ClassSession>>(
                  future: fetchPopularClasses(request),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("Belum ada jadwal kelas tersedia.",
                            style: TextStyle(color: Colors.grey)),
                      );
                    } else {
                      return Column(
                        children: [
                          // List Kartu Kelas
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(), // Scroll ikut parent
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final session = snapshot.data![index];
                              
                              // Persiapkan data untuk ClassCard
                              // Convert code hari (misal "0") ke nama hari ("Monday")
                              final daysNames = session.days
                                  .map((d) => _getDayName(d))
                                  .toList();
                              
                              // Buat dailyMap sederhana (satu hari mapping ke ID sesi itu sendiri)
                              // Karena di list popular ini kita menampilkan per-item (session instance),
                              // bukan grouping seperti di halaman katalog.
                              Map<String, int> dailyMap = {};
                              if (daysNames.isNotEmpty) {
                                dailyMap[daysNames.first] = session.id;
                              }

                              return ClassCard(
                                session: session,
                                baseTitle: _baseTitle(session.title),
                                daysNames: daysNames,
                                dailySessionMap: dailyMap,
                                onRefresh: () {
                                  setState(() {}); // Refresh jika ada booking
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // Tombol "View All Classes"
                          Center(
                            child: InkWell(
                              onTap: () {
                                widget.onNavigateTo(2); // Pindah ke Tab Index 2 (Classes)
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFC9D0C1), // #C9D0C1
                                      Color(0xFFA7B29C), // #A7B29C
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      offset: const Offset(0, 4),
                                      blurRadius: 8,
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "View All Classes",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF273225),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward, 
                                        size: 18, color: Color(0xFF273225)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),

                const SizedBox(height: 80), // Spacer bawah
              ],
            ),
          ),
        ),
      ),
    );
  }
}