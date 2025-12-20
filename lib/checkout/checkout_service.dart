// lib/checkout/checkout_service.dart

import 'dart:convert';

import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:lume_mobile/config/api_config.dart';

import '../models/checkout.dart';

/// Data form checkout yang dikirim ke Django.
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

  /// Konversi ke JSON dengan key snake_case untuk Django.
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

/// Service untuk semua komunikasi checkout <-> Django.
class CheckoutService {
  const CheckoutService();

  /// Ambil ringkasan keranjang (item + subtotal + shipping + total).
  ///
  /// Kalau [selectedOnly] = true, hanya item dengan is_selected = true
  /// yang diambil (sesuai dengan cart_summary_api di Django).
  Future<CartSummary> fetchCartSummary(
    CookieRequest request, {
    bool selectedOnly = true,
  }) async {
    final query = selectedOnly ? '?selected=1' : '';
    final url = apiPath('/checkout/api/cart-summary/$query');

    try {
      // pbp_django_auth sudah otomatis decode JSON -> Map/List
      final dynamic response = await request.get(url);

      if (response is! Map<String, dynamic>) {
        throw Exception('Format respons tidak sesuai');
      }

      return CartSummary.fromJson(response);
    } catch (e) {
      // lempar lagi biar bisa ditangkap di UI (FutureBuilder / try-catch)
      throw Exception('Gagal mengambil cart summary: $e');
    }
  }

  /// Kirim data checkout ke Django dan terima hasilnya.
  ///
  /// Backend akan mengembalikan JSON:
  /// {
  ///   "success": true/false,
  ///   "message": "...",
  ///   "order_id": "...",
  ///   "subtotal": ...,
  ///   "shipping": ...,
  ///   "total": ...
  /// }
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

      // Walaupun success = false, kita tetap parsing ke OrderResult,
      // nanti UI yang akan baca result.success dan tampilkan error.
      return OrderResult.fromJson(response);
    } catch (e) {
      // Kalau sampai sini berarti gagal konek / error lain,
      // kita bikin OrderResult gagal dengan message generic.
      return OrderResult(
        success: false,
        message: 'Gagal memproses checkout: $e',
      );
    }
  }
}
