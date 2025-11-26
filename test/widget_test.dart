import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Pastikan nama package sesuai dengan yang ada di pubspec.yaml kamu
// Kalau di pubspec.yaml namanya 'lume', pakai 'package:lume/main.dart'
import 'package:lume_mobile/main.dart'; 

void main() {
  testWidgets('Home page loads correctly', (WidgetTester tester) async {
    // 1. Build aplikasi Lume
    await tester.pumpWidget(const MyApp());
    
    // Tunggu semua animasi/gambar loading selesai (opsional, kadang perlu pumpAndSettle)
    await tester.pump(); 

    // 2. Cek apakah tulisan "Featured Products" muncul di layar
    // (Karena kita tahu tulisan ini ada di HomePage)
    expect(find.text('Featured Products'), findsOneWidget);

    // 3. Cek apakah icon "Produk" (Storefront) ada di navigasi/tombol
    // (Sesuaikan dengan icon yang kamu pakai, misal Icons.storefront_outlined atau chevron)
    expect(find.byIcon(Icons.chevron_right), findsWidgets); 
  });
}