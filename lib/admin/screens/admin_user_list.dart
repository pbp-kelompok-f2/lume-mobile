import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/models/admin_models.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/widgets/lume_app_bar.dart';
import 'package:lume_mobile/config/api_config.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AdminUserListPage extends StatefulWidget {
  const AdminUserListPage({super.key});

  @override
  State<AdminUserListPage> createState() => _AdminUserListPageState();
}

class _AdminUserListPageState extends State<AdminUserListPage> {
  Future<List<AdminUser>> fetchUsers(CookieRequest request) async {
    final response = await request.get(apiPath('/useradmin/api/users/'));
    List<AdminUser> list = [];
    if (response['ok'] == true) {
      for (var d in response['users']) {
        list.add(AdminUser.fromJson(d));
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      appBar: const LumeAppBar(title: "All Users"),
      body: FutureBuilder(
        future: fetchUsers(request),
        builder: (context, AsyncSnapshot<List<AdminUser>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: LumeColors.sageGreen));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No users found."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = snapshot.data![index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 237, 233, 222),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: LumeColors.sageGreen.withOpacity(0.2),
                      child: Text(user.username[0].toUpperCase(), style: const TextStyle(color: LumeColors.darkGreen)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.username, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(user.email, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildTag(Icons.shopping_bag, "${user.totalOrders} Orders"),
                              const SizedBox(width: 8),
                              _buildTag(Icons.calendar_today, "${user.totalBookings} Bookings"),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTag(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.inter(fontSize: 15, color: Colors.grey[700])),
      ],
    );
  }
}
