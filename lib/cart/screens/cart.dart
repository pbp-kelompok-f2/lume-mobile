import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lume_mobile/models/cart_items.dart';
import 'package:lume_mobile/theme/lume_colors.dart'; // Import LumeColors

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> _cartItems = [];
  // State lokal untuk menyimpan ID item yang dicentang
  final Set<int> _selectedItemIds = {}; 
  bool _isLoading = true;

  // Ganti URL ini dengan URL backend Django lokal/deploy kamu
  final String baseUrl = "http://127.0.0.1:8000"; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCartItems();
    });
  }

  Future<void> _fetchCartItems() async {
    final request = context.read<CookieRequest>();
    try {
      var response = await request.get('$baseUrl/cart/api/get-cart/'); 
      
      List<CartItem> items = [];
      for (var d in response) {
        if (d != null) {
          items.add(CartItem.fromJson(d));
        }
      }

      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching cart: $e");
      setState(() => _isLoading = false);
    }
  }

  // Hitung Total Harga (hanya item yang dicentang)
  double get _totalPrice {
    double total = 0;
    for (var item in _cartItems) {
      if (_selectedItemIds.contains(item.id)) {
        total += (item.price * item.quantity);
      }
    }
    return total;
  }

  // Toggle seleksi semua item
  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedItemIds.addAll(_cartItems.map((e) => e.id));
      } else {
        _selectedItemIds.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Cek apakah semua item terpilih untuk status checkbox 'Select All'
    bool isAllSelected = _cartItems.isNotEmpty && _selectedItemIds.length == _cartItems.length;

    return Scaffold(
      backgroundColor: LumeColors.creamBackground, // Background Cream
      appBar: AppBar(
        title: const Text(
          "Shopping Cart",
          style: TextStyle(
            color: LumeColors.darkText, 
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: LumeColors.creamBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: LumeColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: LumeColors.darkGreen))
          : Column(
              children: [
                // === Bagian List Items ===
                Expanded(
                  child: _cartItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_bag_outlined, size: 64, color: LumeColors.mutedText.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              const Text("Your cart is empty", style: TextStyle(color: LumeColors.mutedText)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: _cartItems.length,
                          separatorBuilder: (ctx, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final item = _cartItems[index];
                            return _buildCartItemCard(item);
                          },
                        ),
                ),
                
                // === Bagian Order Summary (Bottom Sheet style) ===
                if (_cartItems.isNotEmpty) 
                  _buildOrderSummary(isAllSelected),
              ],
            ),
    );
  }

  // Widget Kartu Produk (Sesuai Desain: Checkbox -> Gambar -> Info -> Kontrol)
  Widget _buildCartItemCard(CartItem item) {
    bool isSelected = _selectedItemIds.contains(item.id);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LumeColors.cardBackground, // Background Beige/Card
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 0. Checkbox
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: isSelected,
              activeColor: LumeColors.darkGreen,
              side: const BorderSide(color: LumeColors.mutedText, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    _selectedItemIds.add(item.id);
                  } else {
                    _selectedItemIds.remove(item.id);
                  }
                });
              },
            ),
          ),
          const SizedBox(width: 12),

          // 1. Gambar Produk
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.image.startsWith('http') ? item.image : '$baseUrl/media/${item.image}',
              width: 70,
              height: 90, // Agak memanjang vertikal sesuai desain
              fit: BoxFit.cover,
              errorBuilder: (ctx, error, stackTrace) => 
                  Container(width: 70, height: 90, color: Colors.grey[300], child: const Icon(Icons.image)),
            ),
          ),
          const SizedBox(width: 16),

          // 2. Info Produk (Nama & Harga)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                    color: LumeColors.darkText,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  "Rp ${item.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                  style: const TextStyle(
                    color: LumeColors.mutedText, 
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // 3. Delete & Quantity Control
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Quantity Controller (- 1 +)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: LumeColors.brownBorder),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    _buildQtyBtn(Icons.remove, () {
                      if (item.quantity > 1) { 
                        // Tambahkan logika decrement ke backend
                        setState(() => item.quantity--);
                      }
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: LumeColors.darkText),
                      ),
                    ),
                    _buildQtyBtn(Icons.add, () {
                      // Tambahkan logika increment ke backend
                      setState(() => item.quantity++);
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Tombol Hapus (Icon Sampah)
              InkWell(
                onTap: () async {
                   // Implementasi logika hapus ke backend
                   // await request.post('$baseUrl/cart/delete/${item.id}/', {});
                   setState(() {
                     _cartItems.removeAt(_cartItems.indexOf(item));
                     _selectedItemIds.remove(item.id);
                   });
                },
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.delete_outline, color: Color(0xFFE57373), size: 22),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 14, color: LumeColors.darkText),
      ),
    );
  }

  // Widget Order Summary di bagian bawah
  Widget _buildOrderSummary(bool isAllSelected) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white, // Bagian bawah putih/bersih agar kontras dengan cream
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Select All Checkbox (Opsional, sesuai kebiasaan Cart)
          Row(
            children: [
              SizedBox(
                width: 24, height: 24,
                child: Checkbox(
                  value: isAllSelected,
                  activeColor: LumeColors.darkGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  onChanged: _toggleSelectAll,
                ),
              ),
              const SizedBox(width: 8),
              const Text("Select All Items", style: TextStyle(color: LumeColors.mutedText)),
              const Spacer(),
            ],
          ),
          const Divider(height: 24, color: LumeColors.brownBorder),
          
          const Text(
            "Order Summary",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: LumeColors.darkText),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total (${_selectedItemIds.length} items)", style: const TextStyle(color: LumeColors.mutedText, fontSize: 15)),
              Text(
                "Rp ${_totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: LumeColors.darkText),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Tombol Checkout
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _selectedItemIds.isEmpty ? null : () {
                // Navigate to Checkout Page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: LumeColors.darkGreen, // Warna Dark Green
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Proceed to Checkout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 18)
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tombol Continue Shopping
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: LumeColors.brownBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26), // Capsule shape
                ),
              ),
              child: const Text(
                "Continue Shopping",
                style: TextStyle(color: LumeColors.mutedText, fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}