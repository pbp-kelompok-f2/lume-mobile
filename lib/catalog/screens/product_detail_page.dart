import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  void _addToCart(CookieRequest request) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Processing..."), duration: Duration(milliseconds: 500)),
    );

    try {
      final response = await request.postJson(
        "http://localhost:8000/cart/flutter/add/",
        jsonEncode(<String, dynamic>{
          'product_id': widget.product.id,
          'quantity': 1,
        }),
      );

      if (mounted) {
        if (response['ok'] == true) {
          runAddToCartAnimation(imageKey);
          context.read<CartProvider>().fetchCartCount(request);

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${widget.product.name} added to cart!"),
              backgroundColor: LumeColors.sageGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Failed to add"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.read<CookieRequest>();
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
                  ).then((_) => context.read<CartProvider>().fetchCartCount(request));
                },
                child: AddToCartIcon(
                  key: cartKey,
                  badgeOptions: const BadgeOptions(
                    active: false, // Disable built-in badge
                  ),
                  icon: Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      Widget iconBtn = Container(
                        height: 44, width: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Center(
                          child: Icon(Icons.shopping_cart_outlined, color: LumeColors.darkText, size: 24),
                        ),
                      );

                      // Only show badge if counter > 0
                      if (cartProvider.counter > 0) {
                        return Badge(
                          label: Text(
                            "${cartProvider.counter}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: LumeColors.darkGreen,
                          child: iconBtn,
                        );
                      }
                      return iconBtn;
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