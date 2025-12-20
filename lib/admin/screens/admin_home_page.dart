import 'package:flutter/material.dart';
import 'package:lume_mobile/admin/screens/admin_product_list.dart';
import 'package:lume_mobile/admin/screens/admin_class_list_page.dart'; 
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/profile/screens/profile_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminProductListPage(),
    
    const AdminClassListPage(), 
    
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: LumeColors.sageGreen,
        unselectedItemColor: LumeColors.mutedText,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), 
            label: 'Profile',
          ),  
        ],
      ),
    );
  }
}