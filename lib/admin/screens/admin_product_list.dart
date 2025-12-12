import 'package:flutter/material.dart';
import 'package:lume_mobile/admin/screens/admin_product_form.dart';
import 'package:lume_mobile/models/product.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AdminProductListPage extends StatefulWidget {
  const AdminProductListPage({super.key});

  @override
  State<AdminProductListPage> createState() => _AdminProductListPageState();
}

class _AdminProductListPageState extends State<AdminProductListPage> {
  Future<List<Product>> fetchProducts(CookieRequest request) async {
    // Menggunakan endpoint yang sama dengan user biasa, tapi admin punya akses penuh
    final response = await request.get('http://localhost:8000/catalog/api/products/?limit=100');
    
    List<Product> list = [];
    if (response['results'] != null) {
      for (var d in response['results']) {
        if (d != null) list.add(Product.fromJson(d));
      }
    }
    return list;
  }

  Future<void> deleteProduct(CookieRequest request, String id) async {
    try {
      final response = await request.post(
          'http://localhost:8000/catalog/api/products/$id/delete/',
          {} 
      );
      if (response['ok'] == true) {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product deleted successfully")),
        );
        setState(() {}); // Refresh UI
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      appBar: AppBar(
        title: const Text(
          "Kelola Produk",
          style: TextStyle(fontWeight: FontWeight.bold, color: LumeColors.darkText),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Hilangkan tombol back karena ini halaman utama tab
        iconTheme: const IconThemeData(color: LumeColors.darkText),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: LumeColors.sageGreen,
        onPressed: () async {
          // Navigasi ke Form tambah (tanpa parameter product)
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminProductFormPage()),
          );
          setState(() {}); // Refresh setelah balik dari form
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<Product>>(
        future: fetchProducts(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No products found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final product = snapshot.data![index];
              return Card(
                color: LumeColors.cardBackground,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Thumbnail kecil
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.thumbnail,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, error, stackTrace) => 
                            Container(width: 60, height: 60, color: Colors.grey, child: const Icon(Icons.image_not_supported)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Info Produk
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: LumeColors.darkText),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Rp ${product.price} | Stock: ${product.stock}",
                              style: const TextStyle(color: LumeColors.mutedText, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      // Tombol Aksi
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: LumeColors.sageGreen),
                            onPressed: () async {
                              // Navigasi ke Form Edit (bawa parameter product)
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminProductFormPage(product: product),
                                ),
                              );
                              setState(() {}); // Refresh
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              // Dialog konfirmasi
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Delete Product"),
                                  content: Text("Are you sure you want to delete ${product.name}?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        deleteProduct(request, product.id);
                                      },
                                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}