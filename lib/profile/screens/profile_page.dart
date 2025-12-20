import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/auth/screens/login_page.dart';
import 'package:lume_mobile/main/screens/main_scaffold.dart';
import 'package:lume_mobile/profile/screens/purchase_history_page.dart';
import 'package:lume_mobile/profile/screens/booking_history_page.dart';
import 'package:lume_mobile/profile/screens/edit_profile_page.dart';
import 'package:lume_mobile/catalog/screens/wishlist_page.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/providers/user_provider.dart'; // Import Provider
import 'package:lume_mobile/widgets/lume_app_bar.dart';
import 'package:lume_mobile/config/api_config.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lume_mobile/admin/screens/admin_dashboard_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchUserData();
      }
    });
  }

Future<void> _fetchUserData() async {
    final request = context.read<CookieRequest>();
    final userProvider = context.read<UserProvider>();

    if (userProvider.isAdmin) return; 

    try {
      final response = await request.get(apiPath('/user/api/profile/'));
      if (response['ok'] == true) {
        final userData = response['user'];
        
        userProvider.setUsername(
          userData['username'],
          profilePicture: userData['profile_picture'] ?? "",
          isAdmin: userProvider.isAdmin 
        );
      }
    } catch (e) {
      debugPrint("Gagal fetch profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final userProvider = context.watch<UserProvider>(); 

    if (!request.loggedIn) {
      return const LoginPage();
    }

    if (userProvider.isAdmin) {
      return const AdminDashboardPage();
    }

    String username = userProvider.username;
    
    if (username == "Guest" && request.jsonData['username'] != null) {
        username = request.jsonData['username'];
    }

    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      appBar: const LumeAppBar(
        title: "My Profile",
        showBack: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(context, username, userProvider.profilePicture),
            const SizedBox(height: 30),

            _buildMenuTile(
              context: context,
              title: "Wishlist",
              subtitle: "Your saved products",
              icon: Icons.favorite_border,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WishlistPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            _buildMenuTile(
              context: context,
              title: "Purchase History",
              subtitle: "View your product orders",
              icon: Icons.shopping_bag_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PurchaseHistoryPage()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildMenuTile(
              context: context,
              title: "Class Booking History",
              subtitle: "Check your pilates sessions",
              icon: Icons.self_improvement, 
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookingHistoryPage()),
                );
              },
            ),
            
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  final response = await request.logout(
                    apiPath("/user/api/logout/"),
                  );
                  
                  if (response['ok'] == true) { 
                    if (context.mounted) {
                      context.read<UserProvider>().setUsername("Guest"); 
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Successfully logged out!")),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainScaffold(initialIndex: 0),
                        ),
                      );
                    }
                  } else {
                     if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Logout failed.")),
                        );
                     }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB0B5A9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Log Out",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildProfileHeader(BuildContext context, String username, String profilePicUrl) {

    String getProxiedUrl(String originalUrl) {
      if (originalUrl.isEmpty) return "";
      String cleanUrl = originalUrl.replaceFirst(RegExp(r'^https?://'), '');
      return "https://images.weserv.nl/?url=$cleanUrl&w=1000&h=1000fit=cover";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF8E9388),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              color: Colors.grey.shade300,
            ),
            child: ClipOval(
              child: profilePicUrl.isNotEmpty
                  ? Image.network(
                      // Panggil helper function di sini!
                      getProxiedUrl(profilePicUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Jika proxy pun gagal, baru tampilkan icon
                        return const Icon(Icons.person, size: 40, color: Colors.grey);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            color: LumeColors.sageGreen, 
                            strokeWidth: 2
                          )
                        );
                      },
                    )
                  : const Icon(Icons.person, size: 40, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              
              // Tombol Edit Profile
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfilePage(),
                      ),
                    ).then((_) {
                        _fetchUserData();
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5), 
                        width: 1
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.edit_outlined, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          "Edit Profile",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: const Color.fromARGB(255, 237, 233, 222),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EBE0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF6E7D6B), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: LumeColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
