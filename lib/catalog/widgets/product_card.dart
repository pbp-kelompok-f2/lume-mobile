import 'package:flutter/material.dart';
import 'package:lume_mobile/models/product.dart';
import 'package:intl/intl.dart';
import 'package:lume_mobile/catalog/screens/product_detail_page.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
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
              MaterialPageRoute(
                builder: (context) => ProductDetailPage(product: product),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Nama Produk (1 Baris + Ellipsis biar rapi)
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E252B),
                  ),
                ),
                
                const SizedBox(height: 12),

                // --- BAGIAN FOTO (FIXED SIZE) ---
                // Menggunakan AspectRatio agar semua foto ukurannya SAMA (Kotak 1:1)
                AspectRatio(
                  aspectRatio: 1.0, // Rasio 1:1 (Kotak). Ubah jadi 0.8 jika ingin agak tinggi (portrait).
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: const Color(0xFFEBE8DF), // Warna placeholder saat loading
                          child: product.thumbnail.isNotEmpty
                              ? Image.network(
                                  product.thumbnail,
                                  fit: BoxFit.cover, // KUNCI: Gambar mengisi penuh kotak, crop jika perlu
                                  errorBuilder: (ctx, error, stackTrace) =>
                                      const Center(child: Icon(Icons.image_not_supported, color: Colors.white, size: 30)),
                                )
                              : const Center(child: Icon(Icons.photo, color: Colors.white, size: 30)),
                        ),
                      ),
                      // Tag Best Seller
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8E9388),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "Best-seller",
                            style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ---------------------------------

                const Spacer(), // Dorong elemen bawah ke dasar kartu

                const SizedBox(height: 8),

                // Footer: Harga & Tombol Cart
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        currencyFormatter.format(product.price),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E252B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Tombol Cart Kecil
                    InkWell(
                      onTap: () {
                         ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${product.name} added to cart!")),
                         );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8), // Icon only biar muat
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