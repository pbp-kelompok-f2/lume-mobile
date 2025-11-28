import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/models/product.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/catalog/widgets/product_card.dart';
import 'package:lume_mobile/cart/screens/cart.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ProductEntryPage extends StatefulWidget {
  const ProductEntryPage({super.key});

  @override
  State<ProductEntryPage> createState() => _ProductEntryPageState();
}

class _ProductEntryPageState extends State<ProductEntryPage> {
  // --- Data State ---
  List<Product> _displayedProducts = []; // Produk yang tampil di layar
  List<Product> _allCachedProducts = []; // Simpanan semua produk untuk mode filter
  
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
  String _sortOption = "default"; // default, price_asc, price_desc, name_asc
  Timer? _debounce;

  // Cek apakah user sedang mengaktifkan filter/search
  bool get _isFiltering => 
      _searchQuery.isNotEmpty || 
      _minPrice != null || 
      _maxPrice != null || 
      _sortOption != "default";

  @override
  void initState() {
    super.initState();
    // Listener untuk Infinite Scroll (Hanya jalan jika TIDAK sedang filter)
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

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- LOGIC 1: Fetch Paginasi (Mode Normal) ---
  Future<void> _fetchPagedProducts({bool refresh = false}) async {
    final request = context.read<CookieRequest>();
    
    if (refresh) {
      setState(() {
        _isLoading = true;
        _offset = 0;
        _hasMore = true;
        _displayedProducts.clear();
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      // Panggil API dengan limit & offset
      final response = await request.get(
        'http://127.0.0.1:8000/catalog/api/products/?limit=$_limit&offset=$_offset'
      );

      List<Product> newItems = [];
      for (var d in response['results']) {
        if (d != null) newItems.add(Product.fromJson(d));
      }

      if (!mounted) return;

      setState(() {
        _displayedProducts.addAll(newItems);
        _offset += newItems.length;
        if (newItems.length < _limit) _hasMore = false;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      debugPrint("Error pagination: $e");
      if(mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIC 2: Fetch Semua & Filter (Mode Filter) ---
  Future<void> _runFilterMode() async {
    setState(() => _isLoading = true);
    
    // Jika cache masih kosong, ambil SEMUA data dulu dari server
    if (_allCachedProducts.isEmpty) {
      final request = context.read<CookieRequest>();
      try {
        // Ambil limit besar (misal 1000) untuk simulasi "get all"
        final response = await request.get('http://127.0.0.1:8000/catalog/api/products/?limit=1000');
        List<Product> list = [];
        for (var d in response['results']) {
          if (d != null) list.add(Product.fromJson(d));
        }
        _allCachedProducts = list;
      } catch (e) {
        debugPrint("Error fetching all: $e");
      }
    }

    // Terapkan Filter Lokal pada Cache
    List<Product> results = List.from(_allCachedProducts);

    // 1. Search
    if (_searchQuery.isNotEmpty) {
      results = results.where((p) => 
        p.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // 2. Price Range
    if (_minPrice != null) {
      results = results.where((p) => p.price >= _minPrice!).toList();
    }
    if (_maxPrice != null) {
      results = results.where((p) => p.price <= _maxPrice!).toList();
    }

    // 3. Sorting
    switch (_sortOption) {
      case 'price_asc':
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'name_asc':
        results.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    if (mounted) {
      setState(() {
        _displayedProducts = results;
        _isLoading = false;
      });
    }
  }

  // Handle Input Search
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
      // Jika query kosong dan tidak ada filter lain -> Balik ke Paginasi
      if (!_isFiltering) {
        _fetchPagedProducts(refresh: true);
      } else {
        _runFilterMode();
      }
    });
  }

  // Modal Filter (Bottom Sheet)
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(top: 24, left: 24, right: 24, bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Filter & Sort", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Sort By", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip("Default", "default"),
                _buildFilterChip("Lowest Price", "price_asc"),
                _buildFilterChip("Highest Price", "price_desc"),
                _buildFilterChip("Name (A-Z)", "name_asc"),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Price Range (Rp)", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildPriceInput(_minPriceController, "Min", (v) => _minPrice = v)),
                const SizedBox(width: 12),
                const Text("-"),
                const SizedBox(width: 12),
                Expanded(child: _buildPriceInput(_maxPriceController, "Max", (v) => _maxPrice = v)),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Reset Filter
                      _minPrice = null; _maxPrice = null; _sortOption = "default";
                      _minPriceController.clear(); _maxPriceController.clear();
                      Navigator.pop(ctx);
                      // Jika search juga kosong, balik ke mode paginasi
                      if (_searchQuery.isEmpty) {
                        _fetchPagedProducts(refresh: true);
                      } else {
                        _runFilterMode();
                      }
                    },
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text("Reset", style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _runFilterMode(); // Apply Filter
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: LumeColors.sageGreen, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text("Apply", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    bool selected = _sortOption == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (val) {
        setState(() => _sortOption = value);
        Navigator.pop(context);
        _showFilterModal(); // Hack untuk refresh UI modal
      },
      selectedColor: LumeColors.sageGreen,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
    );
  }

  Widget _buildPriceInput(TextEditingController controller, String hint, Function(double?) onChanged) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (val) => onChanged(double.tryParse(val)),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      appBar: AppBar(
        backgroundColor: LumeColors.creamBackground,
        elevation: 0,
        title: const Text("Products", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: LumeColors.darkText, letterSpacing: -0.5)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // --- SEARCH BAR & FILTER ---
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
                        suffixIcon: IconButton(
                          icon: Icon(Icons.tune, color: _isFiltering ? LumeColors.sageGreen : Colors.grey),
                          onPressed: _showFilterModal,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // --- TOMBOL CART (SUDAH DIPERBAIKI) ---
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
                      // Navigasi ke Halaman Cart yang sudah dibuat sebelumnya
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- GRID PRODUK ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _displayedProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text("No products found.", style: GoogleFonts.inter(fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      )
                    : GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                        // Tambahkan indikator loading di bawah jika Infinite Scroll aktif
                        itemCount: _displayedProducts.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _displayedProducts.length) {
                            return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                          }
                          return ProductCard(product: _displayedProducts[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}