import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:lume_mobile/models/cart_items.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/checkout/screens/checkout_page.dart';

import 'package:lume_mobile/auth/screens/login_page.dart'; 

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> _cartItems = [];
  final Set<int> _selectedItemIds = {};
  bool _isLoading = true;

  final String baseUrl = "http://localhost:8000";

 @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();

      // Kalau belum login -> redirect ke halaman login
      if (!request.loggedIn) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginPage(showBack: true),
            ),
          );
        return;
      }

      // Kalau sudah login -> fetch cart
      _fetchCartItems();
    });
  }

  Future<void> _fetchCartItems() async {
    final request = context.read<CookieRequest>();

    // Defensive: kalau tiba-tiba ke-call tapi user belum login
    if (!request.loggedIn) {
      setState(() {
        _cartItems = [];
        _selectedItemIds.clear();
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Panggil endpoint list flutter
      var response = await request.get('$baseUrl/cart/flutter/list/');

      List<CartItem> items = [];
      if (response['items'] != null) {
        for (var d in response['items']) {
          if (d != null) {
            items.add(CartItem.fromJson(d));
          }
        }
      }

      setState(() {
        _cartItems = items;

        // Inisialisasi selected IDs dari is_selected backend
        _selectedItemIds
          ..clear()
          ..addAll(
            items.where((e) => e.isSelected).map((e) => e.id),
          );

        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching cart: $e");
      if (mounted) setState(() => _isLoading = false);
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

  // Toggle seleksi semua item (sinkron ke backend)
  void _toggleSelectAll(bool? value) async {
    final request = context.read<CookieRequest>();

    if (value == true) {
      // SELECT ALL di backend
      try {
        final response = await request.postJson(
          '$baseUrl/cart/flutter/select-all/',
          jsonEncode(<String, dynamic>{}),
        );

        if (response['ok'] == true) {
          setState(() {
            for (var item in _cartItems) {
              item.isSelected = true;
            }
            _selectedItemIds
              ..clear()
              ..addAll(_cartItems.map((e) => e.id));
          });
        }
      } catch (e) {
        debugPrint("Error select all: $e");
      }
    } else {
      // UNSELECT ALL di backend
      try {
        final response = await request.postJson(
          '$baseUrl/cart/flutter/unselect-all/',
          jsonEncode(<String, dynamic>{}),
        );

        if (response['ok'] == true) {
          setState(() {
            for (var item in _cartItems) {
              item.isSelected = false;
            }
            _selectedItemIds.clear();
          });
        }
      } catch (e) {
        debugPrint("Error unselect all: $e");
      }
    }
  }

  // Toggle satu item (checkbox per item) → sync backend
  Future<void> _toggleItemSelection(CartItem item, bool isSelected) async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.postJson(
        '$baseUrl/cart/flutter/toggle/',
        jsonEncode(<String, dynamic>{
          'item_id': item.id,
          'is_selected': isSelected,
        }),
      );

      if (response['ok'] == true) {
        setState(() {
          item.isSelected = isSelected;
          if (isSelected) {
            _selectedItemIds.add(item.id);
          } else {
            _selectedItemIds.remove(item.id);
          }
        });
      } else {
        final message =
            response['message'] ?? 'Failed to update selection.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      }
    } catch (e) {
      debugPrint("Error toggling selection: $e");
    }
  }

  // Update quantity (sinkron ke set-qty backend)
  Future<void> _updateItemQuantity(int itemId, int newQty) async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.postJson(
        '$baseUrl/cart/flutter/set-qty/',
        jsonEncode(<String, dynamic>{
          'item_id': itemId,
          'quantity': newQty,
        }),
      );

      if (response['ok'] == true) {
        // backend balikin quantity final (bisa 0 kalau di-delete)
        final updatedQty = response['quantity'] ?? newQty;

        setState(() {
          final index = _cartItems.indexWhere((item) => item.id == itemId);
          if (index != -1) {
            if (updatedQty <= 0) {
              // item dihapus di server → hapus juga di UI
              _selectedItemIds.remove(itemId);
              _cartItems.removeAt(index);
            } else {
              _cartItems[index].quantity = updatedQty;
            }
          }
        });
      } else {
        // kasus: stok kurang, dsb.
        final message = response['message'] ?? 'Failed to update quantity.';
        final safeQty = response['quantity'];

        if (safeQty != null) {
          setState(() {
            final index = _cartItems.indexWhere((item) => item.id == itemId);
            if (index != -1) {
              _cartItems[index].quantity = safeQty;
            }
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      }
    } catch (e) {
      debugPrint("Error updating quantity: $e");
    }
  }

  // Delete item (sinkron ke backend)
  Future<void> _deleteItem(int itemId) async {
    final request = context.read<CookieRequest>();

    try {
      final response = await request.postJson(
        '$baseUrl/cart/flutter/remove/',
        jsonEncode(<String, dynamic>{
          'item_id': itemId,
        }),
      );

      if (response['ok'] == true) {
        setState(() {
          _cartItems.removeWhere((item) => item.id == itemId);
          _selectedItemIds.remove(itemId);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item removed from cart.')),
          );
        }
      } else {
        final message = response['message'] ?? 'Failed to remove item.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      }
    } catch (e) {
      debugPrint("Error removing item: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAllSelected =
        _cartItems.isNotEmpty && _cartItems.every((e) => e.isSelected);

    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
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
          icon: const Icon(Icons.arrow_back_ios_new,
              color: LumeColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: LumeColors.darkGreen),
            )
          : Column(
              children: [
                // === List Items ===
                Expanded(
                  child: _cartItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 64,
                                color:
                                    LumeColors.mutedText.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Your cart is empty",
                                style: TextStyle(
                                  color: LumeColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          itemCount: _cartItems.length,
                          separatorBuilder: (ctx, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final item = _cartItems[index];
                            return _buildCartItemCard(item);
                          },
                        ),
                ),

                // === Order Summary ===
                if (_cartItems.isNotEmpty) _buildOrderSummary(isAllSelected),
              ],
            ),
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    bool isSelected = _selectedItemIds.contains(item.id);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: LumeColors.cardBackground,
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
          // Checkbox
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: isSelected,
              activeColor: LumeColors.darkGreen,
              side: const BorderSide(
                color: LumeColors.mutedText,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: (val) {
                if (val == null) return;
                _toggleItemSelection(item, val);
              },
            ),
          ),
          const SizedBox(width: 12),

          // Gambar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              // Handle URL gambar dengan benar (jika relatif tambahkan baseUrl)
              item.image.startsWith('http')
                  ? item.image
                  : '$baseUrl/media/${item.image}',
              width: 70,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (ctx, error, stackTrace) => Container(
                width: 70,
                height: 90,
                color: Colors.grey[300],
                child: const Icon(Icons.image),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info
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
                  "Rp ${item.price.toStringAsFixed(0).replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (Match m) => '${m[1]}.',
                      )}",
                  style: const TextStyle(
                    color: LumeColors.mutedText,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Controls
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: LumeColors.brownBorder),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    _buildQtyBtn(Icons.remove, () {
                      if (item.quantity > 1) {
                        _updateItemQuantity(item.id, item.quantity - 1);
                      } else {
                        // quantity 1 → kirim 0 ke backend, biar dihapus
                        _updateItemQuantity(item.id, 0);
                      }
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: LumeColors.darkText,
                        ),
                      ),
                    ),
                    _buildQtyBtn(Icons.add, () {
                      _updateItemQuantity(item.id, item.quantity + 1);
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _deleteItem(item.id),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.delete_outline,
                    color: Color(0xFFE57373),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 14,
          color: LumeColors.darkText,
        ),
      ),
    );
  }

  Widget _buildOrderSummary(bool isAllSelected) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: Offset(0, -3),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min, // ⬅️ penting biar nggak makan tinggi berlebih
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row Select All
        Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: isAllSelected,
                activeColor: LumeColors.darkGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                onChanged: _toggleSelectAll,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              "Select All Items",
              style: TextStyle(
                color: LumeColors.mutedText,
                fontSize: 13,
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 6),
        const Divider(
          height: 16,
          color: LumeColors.brownBorder,
        ),

        const Text(
          "Order Summary",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16, // tadinya 18
            color: LumeColors.darkText,
          ),
        ),
        const SizedBox(height: 8),

        // Row Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total (${_selectedItemIds.length} items)",
              style: const TextStyle(
                color: LumeColors.mutedText,
                fontSize: 13,
              ),
            ),
            Text(
              "Rp ${_totalPrice.toStringAsFixed(0).replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]}.',
                  )}",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: LumeColors.darkText,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _selectedItemIds.isEmpty
                  ? null
                    : () async {
                        // Pindah ke halaman Checkout
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CheckoutPage(),
                          ),
                        );

                        // Setelah balik dari checkout, refresh cart
                        // (biar item yang sudah di-checkout kehapus dari UI)
                        if (mounted) {
                          _fetchCartItems();
                        }
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: LumeColors.darkGreen,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Proceed to Checkout",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 18,
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Continue shopping
        SizedBox(
          width: double.infinity,
          height: 44, // sedikit lebih pendek
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: LumeColors.brownBorder,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              "Continue Shopping",
              style: TextStyle(
                color: LumeColors.mutedText,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}
