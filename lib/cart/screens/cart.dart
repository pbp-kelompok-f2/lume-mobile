import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lume_mobile/models/cart_items.dart'; 
// import 'package:lume_mobile/screens/checkout_page.dart'; // Jika sudah ada

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> _cartItems = [];
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
      // Pastikan endpoint ini mengembalikan list JSON cart items
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

  // Hitung Total Harga
  double get _totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Latar belakang agak abu seperti desain
      appBar: AppBar(
        title: const Text(
          "Shopping Cart",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // === Bagian List Items ===
                Expanded(
                  child: _cartItems.isEmpty
                      ? const Center(child: Text("Cart is empty"))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _cartItems.length,
                          separatorBuilder: (ctx, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final item = _cartItems[index];
                            return _buildCartItemCard(item);
                          },
                        ),
                ),
                
                // === Bagian Order Summary (Bottom Sheet) ===
                _buildOrderSummary(),
              ],
            ),
    );
  }

  // Widget Kartu Produk (Sesuai Desain: Gambar Kiri, Info Tengah, Kontrol Kanan)
  Widget _buildCartItemCard(CartItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Gambar Produk
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.image.startsWith('http') ? item.image : '$baseUrl/media/${item.image}',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (ctx, error, stackTrace) => 
                  Container(width: 80, height: 80, color: Colors.grey[300], child: const Icon(Icons.image)),
            ),
          ),
          const SizedBox(width: 12),

          // 2. Info Produk (Nama & Harga)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Rp ${item.price.toStringAsFixed(0)}",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor, 
                    fontWeight: FontWeight.w700,
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
              // Tombol Hapus (Icon Sampah)
              InkWell(
                onTap: () async {
                   // Implementasi logika hapus ke backend di sini
                   // await request.post('$baseUrl/cart/delete/${item.id}/', {});
                   // _fetchCartItems();
                },
                child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              ),
              const SizedBox(height: 12),
              
              // Quantity Controller (- 1 +)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _buildQtyBtn(Icons.remove, () {
                      if (item.quantity > 1) { 
                        // Logic update quantity (-)
                      }
                    }),
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    _buildQtyBtn(Icons.add, () {
                      // Logic update quantity (+)
                    }),
                  ],
                ),
              )
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Icon(icon, size: 16, color: Colors.black87),
      ),
    );
  }

  // Widget Order Summary di bagian bawah
  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Summary",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Order Total", style: TextStyle(color: Colors.grey, fontSize: 16)),
              Text(
                "Rp ${_totalPrice.toStringAsFixed(0)}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to Checkout Page
                // Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C3E50), // Warna gelap sesuai desain
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Checkout",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}