import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/booking_kelas/widgets/class_card.dart';
import 'package:lume_mobile/models/booking_kelas.dart';
import 'package:lume_mobile/models/product.dart';
import 'package:lume_mobile/catalog/widgets/product_card.dart';
import 'package:lume_mobile/home/widgets/home_banner.dart';
import 'package:lume_mobile/providers/user_provider.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/config/api_config.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lume_mobile/cart/screens/cart.dart';
import 'package:lume_mobile/providers/cart_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:add_to_cart_animation/add_to_cart_animation.dart';

class HomePage extends StatefulWidget {
  final Function(int) onNavigateTo;

  const HomePage({super.key, required this.onNavigateTo});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;

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
    return map[dayCode] ?? dayCode;
  }

  Future<List<Product>> fetchFeaturedProducts(CookieRequest request) async {
    final response = await request.get(
      apiPath('/catalog/api/products/?limit=5'),
    );
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

  Future<List<ClassSession>> fetchPopularClasses(CookieRequest request) async {
    final response = await request.get(
      apiPath('/bookingkelas/api/popular/'),
    );

    List<ClassSession> allSessions = [];
    var rawData = response;
    
    if (response is Map && response['sessions'] != null) {
      rawData = response['sessions'];
    }

    if (rawData is List) {
      for (var d in rawData) {
        if (d != null) allSessions.add(ClassSession.fromJson(d));
      }
    }

    return allSessions;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final userProvider = context.watch<UserProvider>();
    final String username = userProvider.username;

    return AddToCartAnimation(
      cartKey: cartKey,
      height: 30,
      width: 30,
      opacity: 0.85,
      dragAnimation: const DragToCartAnimationOptions(rotation: false),
      jumpAnimation: const JumpAnimationOptions(),
      createAddToCartAnimation: (runAddToCartAnimation) {
        this.runAddToCartAnimation = runAddToCartAnimation;
      },
      child: Scaffold(
        backgroundColor: LumeColors.creamBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartPage(),
                            ),
                          ).then((_) {
                            if (context.mounted) {
                              context.read<CartProvider>().fetchCartCount(
                                context.read<CookieRequest>(),
                              );
                            }
                          });
                        },
                        child: AddToCartIcon(
                          key: cartKey,
                          badgeOptions: const BadgeOptions(
                            active: false,
                          ),
                          icon: Consumer<CartProvider>(
                            builder: (context, cartProvider, child) {
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

                              if (!request.loggedIn ||
                                  cartProvider.counter <= 0) {
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
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  HomeBanner(
                    onShopNow: () {
                      widget.onNavigateTo(1);
                    },
                    onBookClass: () {
                      widget.onNavigateTo(2);
                    },
                  ),

                  const SizedBox(height: 32),

                  GestureDetector(
                    onTap: () {
                      widget.onNavigateTo(1);
                    },
                    child: Container(
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
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 340,
                      child: FutureBuilder<List<Product>>(
                        future: fetchFeaturedProducts(request),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text(
                                "Belum ada produk featured.",
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          } else {
                            final products = snapshot.data!;
                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 240,
                                  margin: const EdgeInsets.only(right: 16),
                                  child: AppProductCard(
                                    product: products[index],
                                    runAnimation: runAddToCartAnimation,
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

                  Center(
                    child: Text(
                      "Most Popular Classes",
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF6E7D6B),
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
                          child: Text(
                            "Belum ada jadwal kelas tersedia.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      } else {
                        final sessions = snapshot.data!;
                        return Column(
                          children: [
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: sessions.length,
                              itemBuilder: (context, index) {
                                final session = sessions[index];

                                final daysNames = session.days
                                    .map((d) => _getDayName(d))
                                    .toList();

                                Map<String, ClassSession> dailyMap = {}; 
  
                                if (daysNames.isNotEmpty) {

                                  dailyMap[daysNames.first] = session;
                                }

                                return ClassCard(
                                  session: session,
                                  baseTitle: session.title,
                                  daysNames: daysNames,
                                  dailySessionMap: dailyMap,
                                  isPopular: true, 
                                  onRefresh: () {
                                    setState(() {});
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 24),

                            Center(
                              child: InkWell(
                                onTap: () {
                                  widget.onNavigateTo(2);
                                },
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFFC9D0C1),
                                        Color(0xFFA7B29C),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        offset: const Offset(0, 4),
                                        blurRadius: 8,
                                      ),
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
                                      const Icon(
                                        Icons.arrow_forward,
                                        size: 18,
                                        color: Color(0xFF273225),
                                      ),
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

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
