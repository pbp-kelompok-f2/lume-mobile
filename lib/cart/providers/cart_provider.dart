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
    
    // Pastikan host ini konsisten di seluruh aplikasi
    const String baseUrl = "http://127.0.0.1:8000"; 
    
    try {
      final response = await request.get('$baseUrl/cart/flutter/list/');
      
      List<CartItem> items = [];
      
      // KOREKSI UTAMA: Cek jika respons adalah Map (yang benar)
      if (response is Map && response.containsKey('ok')) {
          
          // Hanya proses jika server merespons 200 OK dan flag 'ok' adalah true
          if (response['ok'] == true && response.containsKey('items') && response['items'] is Iterable) {
              
              // Sekarang iterasi pada list yang benar: response['items']
              for (var d in response['items']) { 
                if (d != null) {
                  items.add(CartItem.fromJson(d));
                }
              }
          }
      }
      
      _cartItems = items;
      
    } catch (e) {
      // Ini akan menangkap error FormatException atau koneksi
      debugPrint("Error fetching cart: $e");
    }

    _isLoading = false;
    notifyListeners(); 
  }

  Future<bool> addToCart(CookieRequest request, String productId) async { 
    String baseUrl = "http://127.0.0.1:8000"; // Sesuaikan URL

    final response = await request.postJson(
      "$baseUrl/cart/flutter/add/",
      jsonEncode(<String, dynamic>{
        'product_id': productId, // Kirim UUID string apa adanya
        'quantity': 1,
      }),
    );

    if (response['ok'] == true) {
      await fetchCart(request); 
      return true;
    } else {
      return false;
    }
  }
}