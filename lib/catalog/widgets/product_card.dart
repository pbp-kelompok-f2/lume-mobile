import 'package:flutter/material.dart';
import 'package:lume_mobile/models/product.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Formatter mata uang
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      // Latar belakang kartu (Krem)
      decoration: BoxDecoration(
        color: const Color(0xFFEFECE2), // Warna krem kartu sesuai gambar
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0), // Padding dalam kartu
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header: Nama Produk & Icon Love ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800, // Font tebal (Inter Extrabold)
                      color: Color(0xFF1E252B), // Warna teks hitam/gelap
                    ),
                  ),
                ),
                const Icon(
                  Icons.favorite_border,
                  size: 20,
                  color: Color(0xFF1E252B),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // --- Tengah: Gambar & Tag Best Seller ---
            Expanded(
              child: Stack(
                children: [
                  // Gambar Produk
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFEBE8DF), // Placeholder color
                      child: product.thumbnail.isNotEmpty
                          ? Image.network(
                              product.thumbnail,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, error, stackTrace) =>
                                  const Center(
                                      child: Icon(Icons.image_not_supported,
                                          color: Colors.white, size: 40)),
                            )
                          : const Center(
                              // Icon placeholder jika gambar kosong (seperti di desain)
                              child: Icon(Icons.photo,
                                  color: Colors.white, size: 48),
                            ),
                    ),
                  ),

                  // Tag "Best-seller"
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8E9388), // Warna abu-hijau tag
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Best-seller",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --- Footer: Harga & Tombol Add to Cart ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Harga
                Text(
                  currencyFormatter.format(product.price),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800, // Tebal seperti desain
                    color: Color(0xFF1E252B),
                  ),
                ),

                // Tombol Add to Cart
                InkWell(
                  onTap: () {
                    // Logika tambah ke keranjang
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${product.name} added to cart!")),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA8AF9F), // Warna tombol sage green
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          "Add to Cart",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}