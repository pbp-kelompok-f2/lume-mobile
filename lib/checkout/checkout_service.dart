import 'dart:convert';

import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:lume_mobile/config/api_config.dart';

import '../models/checkout.dart';

class CheckoutFormData {
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String province;
  final String postalCode;
  final String country;
  final String? notes;

  CheckoutFormData({
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.country,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'address_line1': addressLine1,
      'address_line2': addressLine2 ?? '',
      'city': city,
      'province': province,
      'postal_code': postalCode,
      'country': country,
      'notes': notes ?? '',
    };
  }
}

class CheckoutService {
  const CheckoutService();

  Future<CartSummary> fetchCartSummary(
    CookieRequest request, {
    bool selectedOnly = true,
  }) async {
    final query = selectedOnly ? '?selected=1' : '';
    final url = apiPath('/checkout/api/cart-summary/$query');

    try {
      final dynamic response = await request.get(url);

      if (response is! Map<String, dynamic>) {
        throw Exception('Format respons tidak sesuai');
      }

      return CartSummary.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengambil cart summary: $e');
    }
  }

  Future<OrderResult> checkoutCart(
    CookieRequest request,
    CheckoutFormData data,
  ) async {
    final url = apiPath('/checkout/api/cart-checkout/');

    try {
      final dynamic response = await request.postJson(
        url,
        jsonEncode(data.toJson()),
      );

      if (response is! Map<String, dynamic>) {
        throw Exception('Format respons tidak sesuai');
      }

      return OrderResult.fromJson(response);
    } catch (e) {
      return OrderResult(
        success: false,
        message: 'Gagal memproses checkout: $e',
      );
    }
  }
}
