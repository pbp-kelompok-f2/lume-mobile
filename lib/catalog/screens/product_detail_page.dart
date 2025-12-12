import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/models/product.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/cart/screens/cart.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lume_mobile/providers/cart_provider.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  final GlobalKey imageKey = GlobalKey();
  late Function(GlobalKey) runAddToCartAnimation;
  late bool _isWishlisted;

  @override
  void initState() {
    super.initState();
    _isWishlisted = widget.product.isWishlisted;
  }

  Future<void> _addToCart(CookieRequest request) async {
  // 1. Guest → suruh login dulu
  if (!request.loggedIn) {
    _showSnackBar("Please log in before adding items to your cart.");
    return;
  }

  try {
    final response = await request.postJson(
      "http://localhost:8000/cart/flutter/add/",
      jsonEncode(<String, dynamic>{
        'product_id': widget.product.id,
        'quantity': 1,
      }),
    );

    if (!mounted) return;

    if (response['ok'] == true) {
      // sukses -> animasi + update badge + snackbar hijau
      runAddToCartAnimation(imageKey);
      context.read<CartProvider>().fetchCartCount(request);

      _showSnackBar("${widget.product.name} added to cart!");
    } else {
      // gagal -> pakai message dari backend (mis. "Exceeding stock. Only X left.")
      final msg = response['message'] ?? "Failed to add item to cart.";
      _showSnackBar(msg);
    }
  } catch (e) {
    if (!mounted) return;
    _showSnackBar("Error: $e");
  }
}

  Future<void> _toggleWishlist(CookieRequest request) async {
    if (!request.loggedIn) {
      if (!mounted) return;
      _showSnackBar("Please log in to use wishlist.");
      return;
    }

    final previous = _isWishlisted;
    setState(() {
      _isWishlisted = !_isWishlisted;
    });

    try {
      final resp = await request.postJson(
        "http://localhost:8000/catalog/api/wishlist/toggle/${widget.product.id}/",
        jsonEncode(<String, dynamic>{}),
      );
      if (!mounted) return;

      if (resp['ok'] == true) {
        setState(() {
          _isWishlisted = resp['wishlisted'] == true;
        });
      } else {
        setState(() {
          _isWishlisted = previous;
        });
        _showSnackBar("Failed to update wishlist.");
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isWishlisted = previous;
      });
      _showSnackBar("Failed to update wishlist.");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF6E7D6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0
    );

    return AddToCartAnimation(
      cartKey: cartKey,
      height: 30, width: 30, opacity: 0.85,
      dragAnimation: const DragToCartAnimationOptions(rotation: false),
      jumpAnimation: const JumpAnimationOptions(),
      createAddToCartAnimation: (runAddToCartAnimation) {
        this.runAddToCartAnimation = runAddToCartAnimation;
      },
      child: Scaffold(
        backgroundColor: LumeColors.creamBackground,
        
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: IconButton(
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.arrow_back, color: LumeColors.darkText, size: 24),
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          actions: [
  Padding(
    padding: const EdgeInsets.only(right: 16.0),
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartPage()),
        ).then((_) {
          // Hanya fetch kalau user lagi login
          final req = context.read<CookieRequest>();
          if (req.loggedIn) {
            context.read<CartProvider>().fetchCartCount(req);
          }
        });
      },
      child: AddToCartIcon(
        key: cartKey,
        badgeOptions: const BadgeOptions(
          active: false, // Disable built-in badge
        ),
        icon: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            Widget iconBtn = Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Center(
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: LumeColors.darkText,
                  size: 24,
                ),
              ),
            );

            // ❗ Guest ATAU counter 0 → icon polos
            if (!request.loggedIn || cartProvider.counter <= 0) {
              return iconBtn;
            }

            // ✅ Login + ada item → pakai badge hijau
            return Badge(
              label: Text(
                "${cartProvider.counter}",
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: LumeColors.darkGreen,
              child: iconBtn,
            );
          },
        ),
      ),
    ),
  ),
],

        ),
        extendBodyBehindAppBar: true,

        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 400,
                          width: double.infinity,
                          color: const Color(0xFFEFECE2),
                          child: Hero(
                            tag: 'product-img-${widget.product.id}',
                            child: Container(
                              key: imageKey,
                              child: Image.network(
                                widget.product.thumbnail,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, error, stackTrace) => const Center(
                                  child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 64,
                          left: 16,
                          child: InkWell(
                            onTap: () => _toggleWishlist(request),
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isWishlisted ? Icons.favorite : Icons.favorite_border,
                                color: _isWishlisted ? Colors.red : Colors.black87,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        if (!widget.product.inStock)
                          Positioned(
                            bottom: 20, right: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Out of Stock",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),

                    Container(
                      transform: Matrix4.translationValues(0.0, -24.0, 0.0),
                      decoration: const BoxDecoration(
                        color: LumeColors.creamBackground,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: LumeColors.darkText,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currencyFormatter.format(widget.product.price),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: LumeColors.darkText, 
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text("Stock", style: TextStyle(fontSize: 12, color: LumeColors.mutedText)),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.product.inStock ? "${widget.product.stock} available" : "Unavailable",
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: LumeColors.darkText),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: LumeColors.darkText)),
                            const SizedBox(height: 8),
                            Text(
                              widget.product.description.isNotEmpty 
                                  ? widget.product.description 
                                  : "No description available.",
                              style: const TextStyle(fontSize: 15, color: LumeColors.mutedText, height: 1.6),
                            ),
                            const SizedBox(height: 100), 
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: widget.product.inStock ? () => _addToCart(request) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA8AF9F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      widget.product.inStock ? "Add to Cart" : "Unavailable",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
