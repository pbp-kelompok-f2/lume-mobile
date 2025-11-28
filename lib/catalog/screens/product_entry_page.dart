import 'dart:async'; // Tambah ini untuk Timer debounce search
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/models/product.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/catalog/widgets/product_card.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ProductEntryPage extends StatefulWidget {
  const ProductEntryPage({super.key});

  @override
  State<ProductEntryPage> createState() => _ProductEntryPageState();
}

class _ProductEntryPageState extends State<ProductEntryPage> {
  // --- STATE PAGINATION ---
  List<Product> _products = [];
  bool _isFirstLoad = true; // Loading awal (tengah layar)
  bool _isLoadingMore = false; // Loading bawah (spinner kecil)
  bool _hasMore = true; // Apakah masih ada data di server?
  int _offset = 0;
  final int _limit = 6; // Jumlah produk per "halaman"

  // --- STATE SEARCH & FILTER ---
  String _searchQuery = "";
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce; // Biar ga request server tiap ketik 1 huruf

  @override
  void initState() {
    super.initState();
    
    // 1. Setup Scroll Listener (Infinite Scroll)
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 200) {
        // Kalau sudah mau mentok bawah, load lagi
        if (!_isLoadingMore && _hasMore) {
          _fetchProducts();
        }
      }
    });

    // 2. Load Awal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProducts(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- FUNGSI FETCH DATA (PAGINATION) ---
  Future<void> _fetchProducts({bool refresh = false}) async {
    final request = context.read<CookieRequest>();

    if (refresh) {
      if (!mounted) return;
      setState(() {
        _isFirstLoad = true;
        _offset = 0;
        _hasMore = true;
        _products.clear(); // Kosongkan list kalau refresh/search baru
      });
    } else {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      // URL dengan Parameter Pagination & Search
      // limit: jumlah per load
      // offset: mulai dari data ke berapa
      // q: query pencarian
      String url = 'http://127.0.0.1:8000/catalog/api/products/?limit=$_limit&offset=$_offset';
      if (_searchQuery.isNotEmpty) {
        url += '&q=$_searchQuery';
      }

      final response = await request.get(url);
      
      List<Product> newItems = [];
      for (var d in response['results']) {
        if (d != null) {
          newItems.add(Product.fromJson(d));
        }
      }

      if (!mounted) return;

      setState(() {
        // Gabungkan data lama + data baru
        _products.addAll(newItems);
        
        // Update offset untuk fetch berikutnya
        _offset += newItems.length;

        // Cek apakah data sudah habis
        if (newItems.length < _limit) {
          _hasMore = false;
        }

        _isFirstLoad = false;
        _isLoadingMore = false;
      });

    } catch (e) {
      debugPrint("Error fetching products: $e");
      if (mounted) {
        setState(() {
          _isFirstLoad = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  // Fungsi Search dengan Delay (Debounce)
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      setState(() {
        _searchQuery = query;
      });
      _fetchProducts(refresh: true); // Reset dan cari ulang ke server
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      
      appBar: AppBar(
        backgroundColor: LumeColors.creamBackground,
        elevation: 0,
        title: const Text(
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
          // --- Search Bar ---
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
                      onChanged: _onSearchChanged, // Panggil search server-side
                      decoration: InputDecoration(
                        hintText: "Search Products",
                        hintStyle: GoogleFonts.dmSans(color: Colors.grey),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        // Note: Filter tombol bisa ditambahkan disini
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Tombol Cart (Dummy Navigation)
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
                    onPressed: () {
                      // Navigator.pushNamed(context, '/cart');
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- Product Grid (Infinite Scroll) ---
          Expanded(
            child: _isFirstLoad 
              ? const Center(child: CircularProgressIndicator())
              : _products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            "No products found.",
                            style: GoogleFonts.inter(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      controller: _scrollController, // Pasang Controller
                      padding: const EdgeInsets.all(20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.7,
                      ),
                      // Tambah 1 item jika sedang loading bawah (untuk spinner)
                      itemCount: _products.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Jika index melebihi data produk, tampilkan loading spinner
                        if (index == _products.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        // Tampilkan Kartu Produk
                        return ProductCard(product: _products[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}