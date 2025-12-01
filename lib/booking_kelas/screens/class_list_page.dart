import 'package:flutter/material.dart';
import 'package:lume_mobile/booking_kelas/widgets/class_card.dart';
import 'package:lume_mobile/models/booking_kelas.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// Model bantuan untuk menampung data sesi yang sudah di-grouping
class ProcessedSession {
  final ClassSession session; // Instance representatif (biasanya yang pertama)
  final String baseTitle;
  final Map<String, int> dailyMap; // Map Nama Hari -> ID Sesi (Untuk Daily)
  final Set<String> daysNames; // List nama hari untuk ditampilkan (Badge)

  ProcessedSession({
    required this.session,
    required this.baseTitle,
    required this.dailyMap,
    required this.daysNames,
  });
}

class ClassListPage extends StatefulWidget {
  const ClassListPage({super.key});

  @override
  State<ClassListPage> createState() => _ClassListPageState();
}

class _ClassListPageState extends State<ClassListPage> {
  
  // Helper: Mapping angka string '0'-'6' ke Nama Hari (Sesuai views.py)
  String _getDayName(String dayCode) {
    const map = {
      '0': 'Monday', '1': 'Tuesday', '2': 'Wednesday', 
      '3': 'Thursday', '4': 'Friday', '5': 'Saturday', '6': 'Sunday'
    };
    // Jika backend kirim 'Monday' langsung, kembalikan 'Monday'. Jika '0', kembalikan 'Monday'.
    return map[dayCode] ?? dayCode; 
  }

  // Helper: Membersihkan judul (Sesuai views.py _base_title)
  // Misal: "Pilates - Rp50.000" -> "Pilates"
  String _baseTitle(String title) {
    if (title.contains(' - ')) {
      return title.split(' - ').first;
    }
    return title;
  }

  Future<List<ProcessedSession>> fetchAndProcessClasses(CookieRequest request) async {
    // Sesuaikan URL (localhost untuk simulator, 10.0.2.2 untuk emulator Android)
    final response = await request.get('http://127.0.0.1:8000/bookingkelas/json/');
    
    List<ClassSession> allSessions = [];
    if (response is List) {
      for (var d in response) { if (d != null) allSessions.add(ClassSession.fromJson(d)); }
    } else if (response is Map && response['sessions'] != null) {
      for (var d in response['sessions']) { if (d != null) allSessions.add(ClassSession.fromJson(d)); }
    }

    // --- LOGIKA GROUPING (MIRIP VIEWS.PY CATALOG) ---
    // Key Grouping: (Base Title, Time, Category)
    Map<String, ProcessedSession> groups = {};

    for (var s in allSessions) {
      String base = _baseTitle(s.title);
      // Buat key unik gabungan
      String groupKey = "${base}_${s.time}_${s.category}";

      // Konversi list days code (["0"]) jadi list nama hari (["Monday"])
      List<String> currentDayNames = s.days.map((d) => _getDayName(d.toString())).toList();

      if (!groups.containsKey(groupKey)) {
        // Inisialisasi Group Baru
        groups[groupKey] = ProcessedSession(
          session: s, // Simpan instance ini sebagai wakil untuk harga, deskripsi, dll
          baseTitle: base,
          dailyMap: {},
          daysNames: {},
        );
      }

      // Update Group Data
      final group = groups[groupKey]!;
      
      // 1. Tambahkan Nama Hari ke Set (agar unik dan terkumpul)
      group.daysNames.addAll(currentDayNames);

      // 2. Jika Daily, mapping Hari -> ID untuk keperluan Modal
      if (s.category.toLowerCase() == 'daily') {
        // Asumsi Daily per row cuma punya 1 hari, tapi kita loop jg utk aman
        for (var dayName in currentDayNames) {
           group.dailyMap[dayName] = s.id;
        }
      } else {
        // Jika Weekly, ID nya pakai instance ini (biasanya weekly 1 row = banyak hari)
        // Kita bisa pakai ID sesi representative saat booking nanti.
      }
    }

    // Konversi ke List dan Sorting
    List<ProcessedSession> result = groups.values.toList();
    
    // Sort: Category -> Time -> BaseTitle (Sesuai views.py)
    result.sort((a, b) {
      int catCmp = a.session.category.compareTo(b.session.category);
      if (catCmp != 0) return catCmp;
      
      int timeCmp = a.session.time.compareTo(b.session.time);
      if (timeCmp != 0) return timeCmp;

      return a.baseTitle.compareTo(b.baseTitle);
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EE), 
      appBar: AppBar(
        title: const Text("Book A Class"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
            color: Color(0xFF5D4037), fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'
        ),
        iconTheme: const IconThemeData(color: Color(0xFF5D4037)),
      ),
      body: FutureBuilder(
        future: fetchAndProcessClasses(request),
        builder: (context, AsyncSnapshot<List<ProcessedSession>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6E7D6B)));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No classes available.", style: TextStyle(color: Colors.grey)));
          } else {
            return RefreshIndicator(
              color: const Color(0xFF6E7D6B),
              onRefresh: () { setState(() {}); return Future.value(); },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data![index];
                  return ClassCard(
                    session: item.session,
                    baseTitle: item.baseTitle, // Pass judul bersih
                    daysNames: item.daysNames.toList()..sort(), // Pass list hari
                    dailySessionMap: item.dailyMap,
                    onRefresh: () { setState(() {}); },
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}