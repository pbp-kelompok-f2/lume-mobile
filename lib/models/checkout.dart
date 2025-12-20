import 'dart:convert';

CartSummary cartSummaryFromJson(String str) =>
    CartSummary.fromJson(json.decode(str) as Map<String, dynamic>);

String cartSummaryToJson(CartSummary data) => json.encode(data.toJson());

OrderResult orderResultFromJson(String str) =>
    OrderResult.fromJson(json.decode(str) as Map<String, dynamic>);

String orderResultToJson(OrderResult data) => json.encode(data.toJson());

class CartItem {
  final int id;
  final int productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double lineTotal;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
      return 0;
    }

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return CartItem(
      id: parseInt(json['id']),
      productId: parseInt(json['product_id']),
      productName: (json['product_name'] ?? '').toString(),
      unitPrice: parseDouble(json['unit_price']),
      quantity: parseInt(json['quantity']),
      lineTotal: parseDouble(json['line_total']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_id': productId,
    'product_name': productName,
    'unit_price': unitPrice,
    'quantity': quantity,
    'line_total': lineTotal,
  };
}

class CartSummary {
  final List<CartItem> items;
  final double subtotal;
  final double shipping;
  final double total;
  final int count;

  CartSummary({
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.count,
  });

  factory CartSummary.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
      return 0;
    }

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return CartSummary(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: parseDouble(json['subtotal']),
      shipping: parseDouble(json['shipping']),
      total: parseDouble(json['total']),
      count: parseInt(json['count']),
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'subtotal': subtotal,
    'shipping': shipping,
    'total': total,
    'count': count,
  };
}


class OrderResult {
  final bool success;
  final String message;
  final String? orderId;
  final double? subtotal;
  final double? shipping;
  final double? total;

  OrderResult({
    required this.success,
    required this.message,
    this.orderId,
    this.subtotal,
    this.shipping,
    this.total,
  });

  factory OrderResult.fromJson(Map<String, dynamic> json) {
    double? parseDoubleNullable(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return OrderResult(
      success: json['success'] as bool? ?? false,
      message: (json['message'] ?? '').toString(),
      orderId: json['order_id']?.toString(),
      subtotal: parseDoubleNullable(json['subtotal']),
      shipping: parseDoubleNullable(json['shipping']),
      total: parseDoubleNullable(json['total']),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'order_id': orderId,
    'subtotal': subtotal,
    'shipping': shipping,
    'total': total,
  };
}
