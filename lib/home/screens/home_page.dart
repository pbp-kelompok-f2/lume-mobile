import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/models/product.dart';
import 'package:lume_mobile/catalog/widgets/product_card.dart';
import 'package:lume_mobile/home/widgets/home_banner.dart';
import 'package:lume_mobile/providers/user_provider.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// ⬇️ tambahin ini
import 'package:lume_mobile/cart/screens/cart.dart';
import 'package:lume_mobile/providers/cart_provider.dart';

class HomePage extends StatefulWidget {
  // 1. Terima fungsi navigasi dari induk (MainScaffold)
  final Function(int) onNavigateTo;

  const HomePage({super.key, required this.onNavigateTo});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Product>> fetchFeaturedProducts(CookieRequest request) async {
    final response = await request
        .get('http://localhost:8000/catalog/api/products/?limit=5');
    var data = response;
    List<Product> listProduct = [];
    for (var d in data['results']) {
      if (d != null) {
        listProduct.add(Product.fromJson(d));
      }
    }
    return listProduct;
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

                    // ⬇️ GANTI PROFILE ICON → CART ICON + BADGE
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartPage(),
                          ),
                        ).then((_) {
                          // refresh counter setelah balik dari cart
                          context
                              .read<CartProvider>()
                              .fetchCartCount(context.read<CookieRequest>());
                        });
                      },
                      child: Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          // tampilan dasar icon cart
                          Widget cartIcon = Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            child: const Icon(
                              Icons.shopping_cart_outlined,
                              color: LumeColors.darkText,
                            ),
                          );

                          // kalau count > 0 → bungkus dengan Badge hijau
                          if (cartProvider.counter > 0) {
                            return Badge(
                              label: Text(
                                '${cartProvider.counter}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: LumeColors.darkGreen,
                              child: cartIcon,
                            );
                          }

                          // kalau 0 → icon polos
                          return cartIcon;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 2. HomeBanner: tombol Shop Now pindah ke tab Products
                HomeBanner(
                  onShopNow: () {
                    widget.onNavigateTo(1); // Index 1 adalah tab "Products"
                  },
                ),

                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
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
                        if (snapshot.data == null) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text(
                                "Belum ada produk featured.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          } else {
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 240,
                                  margin: const EdgeInsets.only(right: 16),
                                  child: AppProductCard(
                                    product: snapshot.data![index],
                                    runAnimation:
                                        (GlobalKey<State<StatefulWidget>> p1) {},
                                  ),
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
