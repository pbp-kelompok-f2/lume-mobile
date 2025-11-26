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

  // Daftar Halaman
  final List<Widget> _screens = [
    const HomePage(),           // Index 0
    const ProductEntryPage(),   // Index 1
    const Center(child: Text("Classes (Coming Soon)")), // Index 2
    const Center(child: Text("Profile (Coming Soon)")), // Index 3
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body ganti-ganti sesuai index
      body: _screens[_selectedIndex],

      // Bottom Navbar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: LumeColors.creamBackground,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF6E7D6B), // Dark Green active
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: _onItemTapped,
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