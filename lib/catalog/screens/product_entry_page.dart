import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/models/product.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/catalog/widgets/product_card.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart'; // Import ini
import 'package:provider/provider.dart'; // Import ini

class ProductEntryPage extends StatefulWidget {
  const ProductEntryPage({super.key});

  @override
  State<ProductEntryPage> createState() => _ProductEntryPageState();
}

class _ProductEntryPageState extends State<ProductEntryPage> {
  
  // Fungsi untuk mengambil data dari Django
  Future<List<Product>> fetchProduct(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/catalog/api/products/');

    // Melakukan decode response menjadi bentuk json
    var data = response;

    // Konversi data json menjadi object Product
    List<Product> listProduct = [];
    
    // Perhatikan struktur JSON dari Django kamu: 
    // {"count": 10, "results": [...]}
    // Jadi kita ambil data['results']
    for (var d in data['results']) {
      if (d != null) {
        listProduct.add(Product.fromJson(d));
      }
    }
    return listProduct;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      
      appBar: AppBar(
        backgroundColor: LumeColors.creamBackground,
        elevation: 0,
        title: Text(
          "Products",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: LumeColors.darkText,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),

      body: Column(
        children: [
          // --- Search Bar (Tetap Sama) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: const Icon(Icons.tune, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: LumeColors.darkText),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),

          // --- Product Grid dengan FutureBuilder ---
          Expanded(
            child: FutureBuilder(
              future: fetchProduct(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  if (!snapshot.hasData) {
                    return const Column(
                      children: [
                        Text(
                          "Tidak ada data produk.",
                          style: TextStyle(color: Color(0xff59A5D8), fontSize: 20),
                        ),
                        SizedBox(height: 8),
                      ],
                    );
                  } else {
                    return GridView.builder(
                      padding: const EdgeInsets.only(top: 16, bottom: 80, left: 16, right: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (_, index) => ProductCard(product: snapshot.data![index]),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}