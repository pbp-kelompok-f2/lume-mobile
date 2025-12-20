import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/models/product.dart';
import 'package:intl/intl.dart';
import 'package:lume_mobile/catalog/screens/product_detail_page.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/config/api_config.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lume_mobile/providers/cart_provider.dart'; 
import 'dart:convert';
import 'package:lume_mobile/auth/screens/login_page.dart';

class AppProductCard extends StatefulWidget {
  final Product product;
  final Function(GlobalKey) runAnimation; 
  final ValueChanged<bool>? onWishlistChanged;

  const AppProductCard({
    super.key, 
    required this.product, 
    required this.runAnimation,
    this.onWishlistChanged,
  });

  @override
  State<AppProductCard> createState() => _AppProductCardState();
}

class _AppProductCardState extends State<AppProductCard> {
  final GlobalKey widgetKey = GlobalKey(); 
  late bool _isWishlisted;

  @override
  void initState() {
    super.initState();
    _isWishlisted = widget.product.isWishlisted;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final request = context.watch<CookieRequest>();

    if (!request.loggedIn && _isWishlisted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _isWishlisted = false);
        }
      });
    }
  }

  void _handleAddToCart(CookieRequest request) async {
    if (!request.loggedIn) {
  if (!mounted) return;

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const LoginPage(showBack: true),
    ),
  );
  return;
}
    try {
      final response = await request.postJson(
        apiPath("/cart/flutter/add/"),
        jsonEncode(<String, dynamic>{
          'product_id': widget.product.id,
          'quantity': 1,
        }),
      );

      if (!mounted) return;

      if (response['ok'] == true) {
        widget.runAnimation(widgetKey);
        context.read<CartProvider>().fetchCartCount(request);

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showSnackBar("${widget.product.name} added to cart!");
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showSnackBar(response['message'] ?? "Failed to add");
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Error: $e");
    }
  }

  void _showOutOfStockMessage() {
    if (!mounted) return;
    _showSnackBar("Product is out of stock.");
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
        apiPath("/catalog/api/wishlist/toggle/${widget.product.id}/"),
        jsonEncode(<String, dynamic>{}),
      );
      if (!mounted) return;

      if (resp['ok'] == true) {
        setState(() {
          _isWishlisted = resp['wishlisted'] == true;
        });
        widget.onWishlistChanged?.call(_isWishlisted);
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
    final request = context.read<CookieRequest>();
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0
    );
    final bool isOutOfStock =
        !widget.product.inStock || widget.product.stock <= 0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEFECE2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductDetailPage(product: widget.product)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E252B)),
                ),
                const SizedBox(height: 12),

                AspectRatio(
                  aspectRatio: 1.0, 
                  child: Container(
                    key: widgetKey,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: widget.product.displayThumbnail.isNotEmpty
                                ? Image.network(
                                    widget.product.displayThumbnail,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  )
                                : const Center(child: Icon(Icons.photo)),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () => _toggleWishlist(request),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isWishlisted
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    _isWishlisted ? Colors.red : Colors.black87,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        if (isOutOfStock)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                color: Colors.black.withOpacity(0.45),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Out of stock',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        currencyFormatter.format(widget.product.price),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1E252B)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    
                    InkWell(
                      onTap: isOutOfStock
                          ? _showOutOfStockMessage
                          : () => _handleAddToCart(request),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isOutOfStock
                              ? Colors.grey
                              : const Color(0xFFA8AF9F),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.shopping_cart_outlined, size: 16, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
