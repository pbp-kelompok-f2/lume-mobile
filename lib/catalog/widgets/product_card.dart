import 'package:flutter/material.dart';
import 'package:lume_mobile/models/product.dart';
import 'package:intl/intl.dart';
import 'package:lume_mobile/catalog/screens/product_detail_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lume_mobile/providers/cart_provider.dart'; // Pastikan import provider
import 'dart:convert';

class AppProductCard extends StatefulWidget {
  final Product product;
  final Function(GlobalKey) runAnimation; 

  const AppProductCard({
    super.key, 
    required this.product, 
    required this.runAnimation
  });

  @override
  State<AppProductCard> createState() => _AppProductCardState();
}

class _AppProductCardState extends State<AppProductCard> {
  final GlobalKey widgetKey = GlobalKey(); 

  void _handleAddToCart(CookieRequest request) async {
    // Hapus animasi dari sini, kita pindahkan ke bawah setelah request sukses
    
    // Kirim Request ke Server
    try {
      final response = await request.postJson(
        "http://localhost:8000/cart/flutter/add/", // Ganti 10.0.2.2 jika emulator
        jsonEncode(<String, dynamic>{
          'product_id': widget.product.id,
          'quantity': 1,
        }),
      );

      if (mounted) {
        if (response['ok'] == true) {
          // --- SUKSES: BARU JALANKAN ANIMASI ---
          widget.runAnimation(widgetKey);
          
          // Update badge cart
          context.read<CartProvider>().fetchCartCount(request);

          // Optional: Hapus snackbar success jika animasi sudah cukup mewakili
          // atau biarkan tetap ada sebagai konfirmasi teks
          /* ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Added to cart"), duration: Duration(seconds: 1)),
          ); */
        } else {
          // --- GAGAL: TAMPILKAN ERROR (TANPA ANIMASI) ---
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Failed to add"), 
              backgroundColor: Colors.red
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

                // --- BAGIAN FOTO (Key Animasi di sini) ---
                AspectRatio(
                  aspectRatio: 1.0, 
                  child: SizedBox(
                    key: widgetKey, // SUMBER ANIMASI
                    width: double.infinity,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: widget.product.thumbnail.isNotEmpty
                              ? Image.network(
                                  widget.product.thumbnail,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                              : const Center(child: Icon(Icons.photo)),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Spacer(),
                const SizedBox(height: 8),

                // Footer
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
                    
                    // Tombol Add to Cart
                    InkWell(
                      onTap: () => _handleAddToCart(request),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA8AF9F),
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