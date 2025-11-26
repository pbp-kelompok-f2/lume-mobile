import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/cart/screens/cart.dart';
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
  // State untuk Data
  List<Product> _allProducts = []; // Data mentah dari API
  List<Product> _displayedProducts =
      []; // Data yang ditampilkan (setelah difilter)
  bool _isLoading = true;

  // State untuk Search & Filter
  String _searchQuery = "";
  double? _minPrice;
  double? _maxPrice;
  String _sortOption =
      "default"; // default, price_asc, price_desc, name_asc, name_desc

  // Controller Text Field Filter
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ambil data saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProducts();
    });
  }

  // 1. FUNGSI AMBIL DATA DARI DJANGO
  Future<void> _fetchProducts() async {
    final request = context.read<CookieRequest>();
    setState(() => _isLoading = true);

    try {
      // GANTI URL SESUAI KEBUTUHAN (127.0.0.1 untuk Chrome, 10.0.2.2 untuk Android Emulator)
      final response = await request.get(
        'http://127.0.0.1:8000/catalog/api/products/',
      );

      List<Product> list = [];
      for (var d in response['results']) {
        if (d != null) {
          list.add(Product.fromJson(d));
        }
      }

      setState(() {
        _allProducts = list;
        _displayedProducts = list; // Awalnya tampilkan semua
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching products: $e");
      setState(() => _isLoading = false);
    }
  }

  // 2. FUNGSI LOGIC FILTER & SORT
  void _runFilter() {
    List<Product> results = _allProducts;

    // a. Filter Search Query
    if (_searchQuery.isNotEmpty) {
      results = results
          .where(
            (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // b. Filter Harga Min
    if (_minPrice != null) {
      results = results.where((p) => p.price >= _minPrice!).toList();
    }

    // c. Filter Harga Max
    if (_maxPrice != null) {
      results = results.where((p) => p.price <= _maxPrice!).toList();
    }

    // d. Sorting Logic
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
      case 'name_desc':
        results.sort((a, b) => b.name.compareTo(a.name));
        break;
    }

    setState(() {
      _displayedProducts = results;
    });
  }

  // 3. UI BOTTOM SHEET FILTER
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Agar bisa full screen/resize saat keyboard muncul
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom:
                MediaQuery.of(context).viewInsets.bottom +
                24, // Handle keyboard
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Modal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Filter & Sort",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Section: Sort By ---
              const Text(
                "Sort By",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildSortChip("Default", "default"),
                  _buildSortChip("Lowest Price", "price_asc"),
                  _buildSortChip("Highest Price", "price_desc"),
                  _buildSortChip("Name (A-Z)", "name_asc"),
                ],
              ),

              const SizedBox(height: 24),

              // --- Section: Price Range ---
              const Text(
                "Price Range (Rp)",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Min",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (val) {
                        _minPrice = val.isEmpty ? null : double.tryParse(val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "-",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _maxPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Max",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (val) {
                        _maxPrice = val.isEmpty ? null : double.tryParse(val);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // --- Buttons: Reset & Apply ---
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Reset Logic
                        setState(() {
                          _minPrice = null;
                          _maxPrice = null;
                          _sortOption = "default";
                          _minPriceController.clear();
                          _maxPriceController.clear();
                        });
                        Navigator.pop(context); // Tutup modal dulu
                        _runFilter(); // Jalankan filter (kembali ke default)
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Reset",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Tutup modal
                        _runFilter(); // Jalankan filter
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LumeColors.sageGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Apply",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper Widget buat Chip Sort
  Widget _buildSortChip(String label, String value) {
    bool isSelected = _sortOption == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          // Update state UI modal (perlu StatefulBuilder kalau mau real-time update visual di modal,
          // tapi karena modal me-rebuild saat state parent berubah, ini work)
          _sortOption = value;
          Navigator.pop(
            context,
          ); // Hack kecil: tutup buka lagi biar refresh, atau biarkan user tekan apply
          _showFilterModal(); // Re-open biar kelihatan ke-select
        });
      },
      selectedColor: LumeColors.sageGreen,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
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
          // --- Search Bar & Filter Button ---
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
                      onChanged: (value) {
                        _searchQuery = value;
                        _runFilter(); // Live search
                      },
                      decoration: InputDecoration(
                        hintText: "Search Products",
                        hintStyle: GoogleFonts.dmSans(color: Colors.grey),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        // TOMBOL FILTER DISINI
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.tune,
                            color:
                                (_minPrice != null ||
                                    _maxPrice != null ||
                                    _sortOption != "default")
                                ? LumeColors.sageGreen
                                : Colors.grey,
                          ),
                          onPressed: _showFilterModal,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
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
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: LumeColors.darkText,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- Product Grid ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _displayedProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No products found.",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                    itemCount: _displayedProducts.length,
                    itemBuilder: (_, index) =>
                        ProductCard(product: _displayedProducts[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
