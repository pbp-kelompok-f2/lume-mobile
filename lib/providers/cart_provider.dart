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


  Future<void> fetchCart(CookieRequest request) async {
    _isLoading = true;
    // notifyListeners(); // Opsional, jika ingin loading spinner muncul realtime

    // GANTI URL sesuai device:
    // Android Emulator: 10.0.2.2
    // iOS / Web: 127.0.0.1
    String baseUrl = "http://localhost:8000"; 
    
    try {
      final response = await request.get('$baseUrl/cart/flutter/list/');
      List<CartItem> items = [];
      for (var d in response) {
        if (d != null) {
          items.add(CartItem.fromJson(d));
        }
      }
      _cartItems = items;
    } catch (e) {
      print("Error fetching cart: $e");
    }

    _isLoading = false;
    notifyListeners(); // Memberitahu semua widget (Badge/CartPage) untuk rebuild
  }

  Future<bool> addToCart(CookieRequest request, String productId) async { 
    String baseUrl = "http://localhost:8000"; 

    final response = await request.postJson(
      "$baseUrl/cart/flutter/add/",
      jsonEncode(<String, dynamic>{
        'product_id': productId, // Kirim UUID string apa adanya
        'quantity': 1,
      }),
    );

    if (response['ok'] == true) {
      await Future.delayed(const Duration(milliseconds: 100));
      await fetchCart(request); 
      return true;
    } else {
      return false;
    }
  }

  Future<void> fetchCartCount(CookieRequest request) async {
    String baseUrl = "http://localhost:8000";
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