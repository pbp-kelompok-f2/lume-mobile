import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:lume_mobile/models/cart_items.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  int _counter = 0;

  int get counter => _counter;
  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;

  // Helper: reset state kalau user belum login / logout
  void reset() {
    _cartItems = [];
    _counter = 0;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCart(CookieRequest request) async {
    // ❗ Kalau belum login → kosongin cart & counter
    if (!request.loggedIn) {
      reset();
      return;
    }

    _isLoading = true;
    // notifyListeners(); // kalau mau ada loading spinner realtime

    const String baseUrl = "http://localhost:8000";

    try {
      final response = await request.get('$baseUrl/cart/flutter/list/');

      List<CartItem> items = [];

      // Sesuai dengan CartPage: response['items']
      if (response != null && response['items'] != null) {
        for (var d in response['items']) {
          if (d != null) {
            items.add(CartItem.fromJson(d));
          }
        }
      }

      _cartItems = items;

      // Update counter dari backend kalau ada, fallback ke length
      if (response != null && response['total_items'] != null) {
        _counter = response['total_items'] as int;
      } else {
        _counter = items.length;
      }
    } catch (e) {
      print("Error fetching cart: $e");
    }

    _isLoading = false;
    notifyListeners(); // Memberitahu semua widget (Badge/CartPage) untuk rebuild
  }

  Future<bool> addToCart(CookieRequest request, String productId) async {
    // ❗ Kalau belum login sebaiknya langsung return false
    if (!request.loggedIn) {
      return false;
    }

    const String baseUrl = "http://localhost:8000";

    final response = await request.postJson(
      "$baseUrl/cart/flutter/add/",
      jsonEncode(<String, dynamic>{
        'product_id': productId, // Kirim UUID string apa adanya
        'quantity': 1,
      }),
    );

    if (response['ok'] == true) {
      // Ambil ulang cart + counter supaya badge ke-update
      await Future.delayed(const Duration(milliseconds: 100));
      await fetchCart(request);
      await fetchCartCount(request);
      return true;
    } else {
      return false;
    }
  }

  Future<void> fetchCartCount(CookieRequest request) async {
    // ❗ Again, kalau belum login → counter = 0
    if (!request.loggedIn) {
      _counter = 0;
      notifyListeners();
      return;
    }

    const String baseUrl = "http://localhost:8000";
    try {
      // Panggil endpoint list untuk dapat total_items
      final response = await request.get('$baseUrl/cart/flutter/list/');

      if (response != null && response['ok'] == true) {
        _counter = response['total_items'] ?? 0;
        notifyListeners(); // Kabari semua widget yang dengar
      }
    } catch (e) {
      print("Gagal ambil jumlah cart: $e");
    }
  }
}
