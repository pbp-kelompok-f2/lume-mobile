// lib/screens/cart.dart
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

const String baseUrl = "http://127.0.0.1:8000"; // TODO: ganti ke URL PWS kamu

class CartEntry {
  final String id;
  final String productName;
  final int price;
  final String thumbnail;
  final int quantity;
  final bool isSelected;

  CartEntry({
    required this.id,
    required this.productName,
    required this.price,
    required this.thumbnail,
    required this.quantity,
    required this.isSelected,
  });

  factory CartEntry.fromJson(Map<String, dynamic> json) {
    return CartEntry(
      id: json['id'].toString(),
      productName: json['product_name'] ?? '',
      price: json['price'] is int
          ? json['price'] as int
          : int.tryParse(json['price'].toString()) ?? 0,
      thumbnail: json['thumbnail'] ?? '',
      quantity: json['quantity'] ?? 0,
      isSelected: json['is_selected'] ?? false,
    );
  }
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _isLoading = false;
  List<CartEntry> _items = [];

  bool get _hasItems => _items.isNotEmpty;

  int get _totalSelectedQuantity => _items
      .where((e) => e.isSelected)
      .fold<int>(0, (sum, e) => sum + e.quantity);

  @override
  void initState() {
    super.initState();
    // fetch di first frame supaya CookieRequest udah ada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final request = context.read<CookieRequest>();
      _fetchCart(request);
    });
  }

  Future<void> _fetchCart(CookieRequest request) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await request.get("$baseUrl/cart/json/");

      List<dynamic> rawItems;

      if (response is Map && response['items'] != null) {
        rawItems = response['items'] as List<dynamic>;
      } else if (response is List) {
        rawItems = response;
      } else {
        rawItems = [];
      }

      setState(() {
        _items = rawItems
            .map((e) => CartEntry.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load cart: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _postAndRefresh(
    CookieRequest request,
    String url, [
    Map<String, String>? body,
    String? successMessage,
  ]) async {
    try {
      final result = await request.post(url, body ?? {});
      if (mounted && (result['message'] != null || successMessage != null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (result['message']?.toString() ?? successMessage)!,
            ),
          ),
        );
      }
      await _fetchCart(request);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Request failed: $e")),
        );
      }
    }
  }

  Future<void> _toggleSelect(
      CookieRequest request, CartEntry item, bool value) async {
    await _postAndRefresh(
      request,
      "$baseUrl/cart/${item.id}/toggle-select/",
      {
        "is_selected": value ? "1" : "0",
      },
    );
  }

  Future<void> _setQuantity(
      CookieRequest request, CartEntry item, int nextQty) async {
    if (nextQty < 0) return;
    await _postAndRefresh(
      request,
      "$baseUrl/cart/${item.id}/set-qty/",
      {
        "quantity": nextQty.toString(),
      },
    );
  }

  Future<void> _removeItem(CookieRequest request, CartEntry item) async {
    await _postAndRefresh(
      request,
      "$baseUrl/cart/${item.id}/remove-ajax/",
    );
  }

  Future<void> _selectAll(CookieRequest request) async {
    await _postAndRefresh(
      request,
      "$baseUrl/cart/select-all/",
      null,
      "Selected all items. ✅",
    );
  }

  Future<void> _unselectAll(CookieRequest request) async {
    await _postAndRefresh(
      request,
      "$baseUrl/cart/unselect-all/",
      null,
      "Unselected all items. ✅",
    );
  }

  Future<void> _checkout(CookieRequest request) async {
    final selectedIds =
        _items.where((e) => e.isSelected).map((e) => e.id).toList();

    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least one item to proceed."),
        ),
      );
      return;
    }

    final payload = {
      "item_ids": selectedIds.join(","),
    };

    try {
      final result = await request.post(
        "$baseUrl/checkout/cart-checkout-page/",
        payload,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${result['message']?.toString() ??
                      "Checkout request sent successfully."} (Check server behavior)",
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Checkout failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final width = MediaQuery.of(context).size.width;

    final isLarge = width >= 1024; 

    return Scaffold(
      backgroundColor: const Color(0xFFF6F2EB), 
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBackButton(context),
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  isLarge
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildLeftPane(request),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 1,
                              child: _buildSummaryCard(request),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildLeftPane(request),
                            const SizedBox(height: 24),
                            _buildSummaryCard(request),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          // Mirip href "Back to Home"
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          // else: kamu bisa push ke MenuPage atau LandingPage di sini
        },
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 16,
          color: Color(0xFF3A342D),
        ),
        label: const Text(
          "Back to Home",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF3A342D),
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          backgroundColor: const Color(0xFFEDE9DE),
          foregroundColor: const Color(0xFF3A342D),
          shape: const StadiumBorder(),
          side: const BorderSide(color: Color(0xFFD6D0C3)),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Your Cart",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF3A342D),
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Review your items before checkout.",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF766E62),
          ),
        ),
      ],
    );
  }

  Widget _buildLeftPane(CookieRequest request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // selection row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Selection",
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF766E62),
              ),
            ),
            Row(
              children: [
                _buildSelectButton(
                  label: "Select all",
                  onTap: _hasItems ? () => _selectAll(request) : null,
                ),
                const SizedBox(width: 8),
                _buildSelectButton(
                  label: "Unselect all",
                  onTap: _hasItems ? () => _unselectAll(request) : null,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (!_hasItems)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                "Your cart is empty.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF766E62),
                ),
              ),
            ),
          )
        else
          Column(
            children: _items
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCartItemCard(request, item),
                    ))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildSelectButton({
    required String label,
    required VoidCallback? onTap,
  }) {
    final bool disabled = onTap == null;
    return OutlinedButton(
      onPressed: disabled ? null : onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        side: const BorderSide(color: Color(0xFFE0D9CA)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor:
            disabled ? Colors.white.withOpacity(0.5) : const Color(0xFFF5F2EB),
        foregroundColor: const Color(0xFF3A342D),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _buildCartItemCard(CookieRequest request, CartEntry item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F2EB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E3D8)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Checkbox(
            value: item.isSelected,
            onChanged: (val) => _toggleSelect(request, item, val ?? false),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(
              color: Color(0xFFB8A88A),
              width: 2,
            ),
            activeColor: const Color(0xFFB8A88A),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE8E3D8)),
              ),
              child: item.thumbnail.isEmpty
                  ? const ColoredBox(color: Color(0xFFEDE9DE))
                  : Image.network(
                      item.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: Color(0xFFEDE9DE),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3A342D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Rp ${item.price.toString()}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF766E62),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              _buildQtyButton(
                icon: "−",
                onTap: () => _setQuantity(request, item, item.quantity - 1),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 28,
                child: Text(
                  item.quantity.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3A342D),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _buildQtyButton(
                icon: "+",
                onTap: () => _setQuantity(request, item, item.quantity + 1),
              ),
            ],
          ),
          IconButton(
            onPressed: () => _removeItem(request, item),
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton({required String icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE8E3D8), width: 2),
          color: Colors.white,
        ),
        alignment: Alignment.center,
        child: Text(
          icon,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3A342D),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(CookieRequest request) {
    final bool canCheckout = _totalSelectedQuantity > 0;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F2EB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E3D8)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Summary",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3A342D),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Items",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF766E62),
                ),
              ),
              Text(
                _totalSelectedQuantity.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF3A342D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canCheckout ? () => _checkout(request) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB8A88A),
                disabledBackgroundColor:
                    const Color(0xFFB8A88A).withOpacity(0.5),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Proceed to Checkout →",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Mirip "Continue Shopping"
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                // atau arahkan ke halaman main/menu
              },
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
                side: const BorderSide(color: Color(0xFFE0D9CA)),
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF3A342D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Continue Shopping",
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
