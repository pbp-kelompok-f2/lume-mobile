import 'package:flutter/material.dart';
import 'package:lume_mobile/catalog/screens/product_entry_page.dart';
import 'package:lume_mobile/home/screens/home_page.dart';
import 'package:lume_mobile/theme/lume_colors.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Kita definisikan list screens DI DALAM build atau gunakan switch case
    // supaya bisa passing fungsi _onItemTapped ke HomePage
    final List<Widget> screens = [
      // Index 0: HomePage (Kirim fungsi navigasi ke sini!)
      HomePage(
        onNavigateTo: (index) => _onItemTapped(index),
      ),
      
      // Index 1: Product Page
      const ProductEntryPage(),   
      
      // Index 2: Classes (Placeholder)
      const Center(child: Text("Classes (Coming Soon)")), 
      
      // Index 3: Profile (Placeholder)
      const Center(child: Text("Profile (Coming Soon)")), 
    ];

    return Scaffold(
      // Body ganti-ganti sesuai index
      body: screens[_selectedIndex],

      // Bottom Navbar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: LumeColors.creamBackground,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF6E7D6B), // Dark Green active
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: _onItemTapped, // Fungsi ini yang dipanggil oleh Navbar maupun Banner
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}