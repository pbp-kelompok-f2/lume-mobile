import 'package:flutter/material.dart';
import 'package:lume_mobile/catalog/screens/product_entry_page.dart';
import 'package:lume_mobile/home/screens/home_page.dart';
import 'package:lume_mobile/profile/screens/profile_page.dart'; 
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/providers/cart_provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lume_mobile/booking_kelas/screens/class_list_page.dart';

class MainScaffold extends StatefulWidget {
  final int initialIndex; 

  const MainScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    
    _selectedIndex = widget.initialIndex; 

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCartOnLoad();
    });
  }

  void _fetchCartOnLoad() async {
    final request = context.read<CookieRequest>();

    if (request.loggedIn) {
      final cartProvider = context.read<CartProvider>();
      try {
        await cartProvider.fetchCart(request);
        debugPrint("Cart fetched successfully from MainScaffold.");
      } catch (e) {
        debugPrint("Error fetching cart on load: $e");
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomePage(
        onNavigateTo: (index) => _onItemTapped(index),
      ),
      const ProductEntryPage(),   
      const ClassListPage(), 
      const ProfilePage(), 
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: LumeColors.creamBackground,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF6E7D6B), 
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center_outlined), activeIcon: Icon(Icons.fitness_center), label: 'Classes'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}