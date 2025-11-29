import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:lume_mobile/models/cart_items.dart'; // Sesuaikan import model Anda

class CartProvider extends ChangeNotifier {
  List<CartItem> _cartItems = [];
  bool _isLoading = false;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;

  // Getter untuk menghitung total item (untuk Badge)
  int get cartCount => _cartItems.length; 
  // Atau jika ingin menghitung berdasarkan quantity:
  // int get cartCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

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
    String baseUrl = "http://localhost:8000"; // Sesuaikan URL

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
}