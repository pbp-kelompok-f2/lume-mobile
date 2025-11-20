// To parse this JSON data, do
//
//     final cartItemEntry = cartItemEntryFromJson(jsonString);

import 'dart:convert';

CartItemEntry cartItemEntryFromJson(String str) => CartItemEntry.fromJson(json.decode(str));

String cartItemEntryToJson(CartItemEntry data) => json.encode(data.toJson());

class CartItemEntry {
    bool ok;
    String message;
    int totalItems;
    int selectedCount;
    int selectedQty;
    List<Item> items;

    CartItemEntry({
        required this.ok,
        required this.message,
        required this.totalItems,
        required this.selectedCount,
        required this.selectedQty,
        required this.items,
    });

    factory CartItemEntry.fromJson(Map<String, dynamic> json) => CartItemEntry(
        ok: json["ok"],
        message: json["message"],
        totalItems: json["total_items"],
        selectedCount: json["selected_count"],
        selectedQty: json["selected_qty"],
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "ok": ok,
        "message": message,
        "total_items": totalItems,
        "selected_count": selectedCount,
        "selected_qty": selectedQty,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
    };
}

class Item {
    int id;
    String productName;
    int price;
    String thumbnail;
    int quantity;
    bool isSelected;

    Item({
        required this.id,
        required this.productName,
        required this.price,
        required this.thumbnail,
        required this.quantity,
        required this.isSelected,
    });

    factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        productName: json["product_name"],
        price: json["price"],
        thumbnail: json["thumbnail"],
        quantity: json["quantity"],
        isSelected: json["is_selected"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "product_name": productName,
        "price": price,
        "thumbnail": thumbnail,
        "quantity": quantity,
        "is_selected": isSelected,
    };
}
