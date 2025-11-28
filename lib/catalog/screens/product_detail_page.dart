import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lume_mobile/models/product.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lume_mobile/cart/providers/cart_provider.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  
  // Ubah fungsi ini menggunakan Provider
  void _addToCart(CookieRequest request) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Adding to cart..."),
        duration: Duration(milliseconds: 500),
      ),
    );

    // Panggil fungsi dari CartProvider
    final success = await context.read<CartProvider>().addToCart(
      request, 
      widget.product.id
    );

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${widget.product.name} added to cart!"),
            backgroundColor: LumeColors.sageGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to add to cart"),
            backgroundColor: Colors.red,
          ),
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

    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          // ... (kode icon back Anda)
          onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back),
        ),
        // TAMBAHKAN ACTION UNTUK BADGE CART
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return Badge(
                  label: Text(cartProvider.cartCount.toString()),
                  isLabelVisible: cartProvider.cartCount > 0,
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: LumeColors.darkText),
                    onPressed: () {
                        // Navigasi ke Cart Page
                        // Navigator.push(...); 
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // --- Scrollable Content ---
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Produk
                  Stack(
                    children: [
                      Container(
                        height: 400,
                        width: double.infinity,
                        color: const Color(0xFFEFECE2),
                        child: Image.network(
                          widget.product.thumbnail,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, error, stackTrace) => const Center(
                            child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                          ),
                        ),
                      ),
                      if (!widget.product.inStock)
                        Positioned(
                          bottom: 20,
                          right: 20,
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

                  // Info Produk Container
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
                          // Nama Produk
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

                          // --- HARGA & STOK (LAYOUT BARU) ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Harga (Kiri)
                              Text(
                                currencyFormatter.format(widget.product.price),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: LumeColors.darkText, 
                                ),
                              ),

                              // Stok (Kanan)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    "Stock",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: LumeColors.mutedText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.product.inStock
                                        ? "${widget.product.stock} available"
                                        : "Unavailable",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: LumeColors.darkText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // -----------------------------------

                          const SizedBox(height: 24),
                          
                          const Text(
                            "Description",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: LumeColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.product.description.isNotEmpty 
                                ? widget.product.description 
                                : "No description available for this product.",
                            style: const TextStyle(
                              fontSize: 15,
                              color: LumeColors.mutedText,
                              height: 1.6,
                            ),
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

          // --- Sticky Bottom Bar ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.product.inStock ? "Add to Cart" : "Unavailable",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}