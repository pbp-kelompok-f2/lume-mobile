import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:lume_mobile/models/cart_items.dart';
import 'package:lume_mobile/config/api_config.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  int _counter = 0;

  int get counter => _counter;
  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;

  void reset() {
    _cartItems = [];
    _counter = 0;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchCart(CookieRequest request) async {
    if (!request.loggedIn) {
      reset();
      return;
    }

    _isLoading = true;

    try {
      final response = await request.get(apiPath('/cart/flutter/list/'));

      List<CartItem> items = [];

      if (response != null && response['items'] != null) {
        for (var d in response['items']) {
          if (d != null) {
            items.add(CartItem.fromJson(d));
          }
        }
      }

      _cartItems = items;

      if (response != null && response['total_items'] != null) {
        _counter = response['total_items'] as int;
      } else {
        _counter = items.length;
      }
    } catch (e) {
      print("Error fetching cart: $e");
    }

    _isLoading = false;
    notifyListeners(); 
  }

  Future<bool> addToCart(
  BuildContext context,
  CookieRequest request,
  String productId,
) async {

  if (!request.loggedIn) {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Login required"),
        content: const Text(
          "Please log in before adding items to your cart.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
    return false;
  }

  final response = await request.postJson(
    apiPath("/cart/flutter/add/"),
    jsonEncode(<String, dynamic>{
      'product_id': productId,
      'quantity': 1,
    }),
  );

  if (response['ok'] == true) {
    await Future.delayed(const Duration(milliseconds: 100));
    await fetchCart(request);
    await fetchCartCount(request);
    return true;
  } else {
    return false;
  }
}


  Future<void> fetchCartCount(CookieRequest request) async {
    if (!request.loggedIn) {
      _counter = 0;
      notifyListeners();
      return;
    }

    try {

      final response = await request.get(apiPath('/cart/flutter/list/'));

      if (response != null && response['ok'] == true) {
        _counter = response['total_items'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      print("Gagal ambil jumlah cart: $e");
    }
  }
}
