import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/admin/screens/admin_class_form_page.dart';
import 'package:lume_mobile/models/booking_kelas.dart';
import 'package:lume_mobile/theme/lume_colors.dart';
import 'package:lume_mobile/widgets/lume_app_bar.dart';
import 'package:lume_mobile/config/api_config.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AdminClassListPage extends StatefulWidget {
  const AdminClassListPage({super.key});

  @override
  State<AdminClassListPage> createState() => _AdminClassListPageState();
}

class _AdminClassListPageState extends State<AdminClassListPage> {
  Future<List<ClassSession>> fetchClasses(CookieRequest request) async {
    final response = await request.get(
      apiPath('/bookingkelas/json/'),
    );

    List<ClassSession> listSessions = [];
    var data = response;
    if (response is Map && response['sessions'] != null) {
      data = response['sessions'];
    }

    if (data is List) {
      for (var d in data) {
        if (d != null) listSessions.add(ClassSession.fromJson(d));
      }
    }
    return listSessions;
  }

  Future<void> deleteClass(CookieRequest request, int id) async {
    try {
      final response = await request.postJson(
        apiPath('/bookingkelas/delete-flutter/$id/'),
        {},
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Class deleted successfully"),
            backgroundColor: LumeColors.sageGreen,
          ),
        );
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Failed to delete"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: LumeColors.creamBackground,
      appBar: const LumeAppBar(
        title: "Manage Classes",
        showBack: false,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: LumeColors.sageGreen,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminClassFormPage()),
          ).then((_) => setState(() {}));
        },
      ),
      body: FutureBuilder(
        future: fetchClasses(request),
        builder: (context, AsyncSnapshot<List<ClassSession>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: LumeColors.sageGreen),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No classes found."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            separatorBuilder: (ctx, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final session = snapshot.data![index];
              return _buildAdminClassCard(session, request);
            },
          );
        },
      ),
    );
  }

  Widget _buildAdminClassCard(ClassSession session, CookieRequest request) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFCFC8BA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  session.title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: LumeColors.darkText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  session.category.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: LumeColors.darkText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _infoRow(Icons.person, session.instructor),
          _infoRow(Icons.access_time, session.time),
          _infoRow(Icons.event, session.days.join(", ")), 
          _infoRow(
            Icons.people,
            "${session.capacityCurrent}/${session.capacityMax}",
          ),

          const Divider(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                label: const Text("Edit", style: TextStyle(color: Colors.blue)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminClassFormPage(
                        session: session,
                      ),
                    ),
                  ).then((_) => setState(() {}));
                },
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                label: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () =>
                    _showDeleteConfirmation(context, request, session),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    CookieRequest request,
    ClassSession session,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to delete '${session.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              deleteClass(request, session.id);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
