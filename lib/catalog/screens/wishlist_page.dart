import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/auth/screens/login_page.dart';
import 'package:lume_mobile/catalog/widgets/product_card.dart';
import 'package:lume_mobile/models/product.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/widgets/lume_app_bar.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  late Future<List<Product>> _wishlistFuture;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _wishlistFuture = Future.value([]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final request = context.read<CookieRequest>();
      _wishlistFuture = _fetchWishlistProducts(request);
      _initialized = true;
    }
  }

  Future<List<Product>> _fetchWishlistProducts(CookieRequest request) async {
    final response = await request.get(
      'http://localhost:8000/catalog/api/products/?limit=200',
    );

    final List<Product> products = [];
    if (response['results'] != null) {
      for (final item in response['results']) {
        if (item != null) {
          final product = Product.fromJson(item);
          if (product.isWishlisted) {
            products.add(product);
          }
        }
      }
    }
    return products;
  }

  Future<void> _refresh() async {
    final request = context.read<CookieRequest>();
    setState(() {
      _wishlistFuture = _fetchWishlistProducts(request);
    });
    await _wishlistFuture;
  }

  void _noopAnimation(GlobalKey _) {}

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    if (!request.loggedIn) {
      return const LoginPage();
    }

    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      appBar: const LumeAppBar(title: 'My Wishlist'),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Product>>(
          future: _wishlistFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Failed to load wishlist.',
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                ),
              );
            }

            final products = snapshot.data ?? [];
            if (products.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 80),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite_border,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          'No items in your wishlist yet.',
                          style:
                              GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: products.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final product = products[index];
                return AppProductCard(
                  product: product,
                  runAnimation: _noopAnimation,
                  onWishlistChanged: (wishlisted) {
                    if (!wishlisted) {
                      _refresh();
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
