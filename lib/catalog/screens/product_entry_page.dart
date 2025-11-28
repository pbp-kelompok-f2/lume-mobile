import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/models/product.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/catalog/widgets/product_card.dart';
import 'package:lume_mobile/cart/screens/cart.dart'; 
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart'; // IMPORT INI

class ProductEntryPage extends StatefulWidget {
  const ProductEntryPage({super.key});

  @override
  State<ProductEntryPage> createState() => _ProductEntryPageState();
}

class _ProductEntryPageState extends State<ProductEntryPage> {
  // --- Animation Keys ---
  GlobalKey<CartIconKey> cartKey = GlobalKey<CartIconKey>();
  late Function(GlobalKey) runAddToCartAnimation;

  // --- Data State ---
  List<Product> _displayedProducts = [];
  List<Product> _allCachedProducts = [];
  
  // --- Pagination State ---
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 6;
  
  // --- Filter & Search State ---
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  
  String _searchQuery = "";
  double? _minPrice;
  double? _maxPrice;
  String _sortOption = "default";
  Timer? _debounce;

  bool get _isFiltering => 
      _searchQuery.isNotEmpty || 
      _minPrice != null || 
      _maxPrice != null || 
      _sortOption != "default";

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!_isFiltering && 
          _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore && 
          _hasMore) {
        _fetchPagedProducts();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPagedProducts(refresh: true);
    });
  }

  // ... (dispose, _fetchPagedProducts, _runFilterMode, _onSearchChanged, _showFilterModal, _buildFilterChip, _buildPriceInput SAMA SEPERTI SEBELUMNYA) ...
  // Biar hemat tempat, saya skip bagian yang tidak berubah. Copy paste dari kode sebelumnya untuk method-method logic tersebut.
  // Pastikan method-method tersebut tetap ada di dalam class ini.

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchPagedProducts({bool refresh = false}) async {
    final request = context.read<CookieRequest>();
    if (refresh) {
      setState(() {
        _isLoading = true; _offset = 0; _hasMore = true; _displayedProducts.clear();
      });
    } else {
      setState(() => _isLoadingMore = true);
    }
    try {
      final response = await request.get('http://127.0.0.1:8000/catalog/api/products/?limit=$_limit&offset=$_offset');
      List<Product> newItems = [];
      for (var d in response['results']) { if (d != null) newItems.add(Product.fromJson(d)); }
      if (!mounted) return;
      setState(() {
        _displayedProducts.addAll(newItems);
        _offset += newItems.length;
        if (newItems.length < _limit) _hasMore = false;
        _isLoading = false; _isLoadingMore = false;
      });
    } catch (e) {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _runFilterMode() async {
     // ... (Copy logika filter dari kode sebelumnya di sini) ...
     // Untuk mempersingkat, asumsikan logika ini sama persis
     setState(() => _isLoading = false); 
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => _searchQuery = query);
      if (!_isFiltering) { _fetchPagedProducts(refresh: true); } else { _runFilterMode(); }
    });
  }

  void _showFilterModal() {
     // ... (Copy logika modal filter dari kode sebelumnya) ...
  }
  
  Widget _buildFilterChip(String label, String value) {
     // ... (Copy logika chip dari kode sebelumnya) ...
     return Container(); // Placeholder
  }

  Widget _buildPriceInput(TextEditingController controller, String hint, Function(double?) onChanged) {
     // ... (Copy logika input dari kode sebelumnya) ...
     return Container(); // Placeholder
  }

  // --- BUILD UTAMA ---
  @override
  Widget build(BuildContext context) {
    return AddToCartAnimation(
      cartKey: cartKey, // Kunci Target (Icon Cart)
      height: 30, // Ukuran gambar saat terbang
      width: 30,
      opacity: 0.85,
      dragAnimation: const DragToCartAnimationOptions(
        rotation: true,
      ),
      jumpAnimation: const JumpAnimationOptions(),
      createAddToCartAnimation: (runAddToCartAnimation) {
        this.runAddToCartAnimation = runAddToCartAnimation;
      },
      child: Scaffold(
        backgroundColor: LumeColors.creamBackground,
        appBar: AppBar(
          backgroundColor: LumeColors.creamBackground,
          elevation: 0,
          title: const Text("Products", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: LumeColors.darkText, letterSpacing: -0.5)),
          centerTitle: false,
        ),
        body: Column(
          children: [
            // --- SEARCH BAR & CART ICON ---
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
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: "Search Products",
                          hintStyle: GoogleFonts.dmSans(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          // Note: Saya disable filter button sementara di kode ini biar ringkas
                          // suffixIcon: ... (tombol filter)
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // --- TARGET ANIMASI (CART ICON) ---
                  AddToCartIcon(
                    key: cartKey,
                    icon: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Icon(Icons.shopping_cart_outlined, color: LumeColors.darkText),
                    ),
                    badge: const SizedBox(), // Bisa diisi badge angka merah nanti
                  ).onClick((_) {
                     // Navigasi ke Halaman Cart saat diklik
                     Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartPage()),
                      );
                  }),
                ],
              ),
            ),

            // --- GRID PRODUK ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _displayedProducts.isEmpty
                      ? const Center(child: Text("No products found."))
                      : GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(20),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: _displayedProducts.length + (_isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _displayedProducts.length) {
                              return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                            }
                            
                            // Panggil ProductCard dan oper fungsi animasi
                            return AppProductCard(
                              product: _displayedProducts[index],
                              runAnimation: runAddToCartAnimation, // OPER FUNGSI KE SINI
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}