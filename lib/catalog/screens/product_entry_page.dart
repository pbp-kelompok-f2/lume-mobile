import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/models/product.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/catalog/widgets/product_card.dart';
// import 'package:pbp_django_auth/pbp_django_auth.dart';
// import 'package:provider/provider.dart';

class ProductEntryPage extends StatefulWidget {
  const ProductEntryPage({super.key});

  @override
  State<ProductEntryPage> createState() => _ProductEntryPageState();
}

class _ProductEntryPageState extends State<ProductEntryPage> {
  // Dummy Data
  final List<Product> _products = [
    Product(
      id: "1",
      name: "Matras",
      price: 400000,
      description: "High quality mat",
      thumbnail: "https://picsum.photos/200/300",
      inStock: true,
    ),
    Product(
      id: "2",
      name: "Yoga Block",
      price: 150000,
      description: "Support block",
      thumbnail: "https://picsum.photos/201/300",
      inStock: true,
    ),
    Product(
      id: "3",
      name: "Strap",
      price: 90000,
      description: "Stretching strap",
      thumbnail: "https://picsum.photos/202/300",
      inStock: true,
    ),
    Product(
      id: "4",
      name: "Bottle",
      price: 250000,
      description: "Water bottle",
      thumbnail: "https://picsum.photos/203/300",
      inStock: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LumeColors.creamBackground,

      // --- App Bar Custom ---
      appBar: AppBar(
        backgroundColor: LumeColors.creamBackground,
        elevation: 0,
        title: Text(
          "Products",
          style: TextStyle(
            // Ganti dari GoogleFonts.playfairDisplay ke TextStyle biasa
            fontSize: 24, // Ukuran disesuaikan (mirip text-3xl)
            fontWeight: FontWeight
                .w800, // w800 = ExtraBold (mirip font-extrabold di Django)
            color: LumeColors.darkText,
            letterSpacing: -0.5, // tracking-tight di Tailwind
          ),
        ),
        centerTitle: false,
      ),

      body: Column(
        children: [
          // --- Search Bar Section ---
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search Products",
                        hintStyle: GoogleFonts.dmSans(color: Colors.grey),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        suffixIcon: const Icon(Icons.tune, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Cart Icon Button
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: LumeColors.darkText,
                    ),
                    onPressed: () {
                      // Navigate to Cart
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- Product Grid ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                padding: const EdgeInsets.only(top: 16, bottom: 80),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: _products[index]);
                },
              ),
            ),
          ),
        ],
      ),

      // bottomNavigationBar SUDAHDIHAPUS dari sini
    );
  }
}
