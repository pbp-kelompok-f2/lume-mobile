import 'package:flutter/material.dart';
import 'package:lume_mobile/booking_kelas/widgets/class_card.dart';
import 'package:lume_mobile/models/booking_kelas.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// Model bantuan untuk menampung data sesi + map hari (khusus daily)
class ProcessedSession {
  final ClassSession session;
  final Map<String, int>? dailyMap; // Map Hari -> ID Sesi

  ProcessedSession(this.session, {this.dailyMap});
}

class ClassListPage extends StatefulWidget {
  const ClassListPage({super.key});

  @override
  State<ClassListPage> createState() => _ClassListPageState();
}

class _ClassListPageState extends State<ClassListPage> {
  
  Future<List<ProcessedSession>> fetchAndProcessClasses(CookieRequest request) async {
    // 1. Fetch RAW data (Semua sesi)
    final response = await request.get('http://10.0.2.2:8000/bookingkelas/json/');
    List<ClassSession> allSessions = [];
    
    if (response is List) {
      for (var d in response) { if (d != null) allSessions.add(ClassSession.fromJson(d)); }
    } else if (response is Map && response['sessions'] != null) {
      for (var d in response['sessions']) { if (d != null) allSessions.add(ClassSession.fromJson(d)); }
    }

    // 2. GROUPING LOGIC
    // Kita ingin hasil akhir maksimal 5 item:
    // Daily 1, Daily 2, Daily 3, Weekly 1, Weekly 2.
    
    // Map untuk menampung grup. Key unik bisa berupa string.
    Map<String, ProcessedSession> groups = {};

    for (var s in allSessions) {
      bool isDaily = s.category.toLowerCase().contains('daily');
      
      if (isDaily) {
        // --- LOGIKA DAILY ---
        // Kelompokkan berdasarkan JAM (Time). 
        // Semua sesi daily di jam 10.00 akan masuk satu grup, bedanya cuma di 'days'.
        String key = "DAILY_${s.time}"; 
        
        if (!groups.containsKey(key)) {
          // Buat entri baru, inisialisasi Map
          groups[key] = ProcessedSession(s, dailyMap: {});
        }
        
        // Masukkan ID sesi ini ke dalam Map berdasarkan harinya
        // Asumsi s.days berisi list string angka ["0"] atau ["1"]
        if (s.days.isNotEmpty) {
           groups[key]!.dailyMap![s.days.first] = s.id;
        }
        
      } else {
        // --- LOGIKA WEEKLY ---
        // Kelompokkan berdasarkan Pola Hari.
        // Weekly (Senin,Rabu,Jumat) vs Weekly (Selasa,Kamis,Sabtu)
        // Kita jadikan list hari string sebagai key unik.
        String dayPattern = s.days.join('_'); 
        String key = "WEEKLY_$dayPattern";

        if (!groups.containsKey(key)) {
          groups[key] = ProcessedSession(s); // Weekly tidak butuh dailyMap
        }
      }
    }

    // 3. Konversi Map ke List dan SORTING
    List<ProcessedSession> result = groups.values.toList();

    // Custom Sort: Daily dulu (berdasarkan jam), baru Weekly
    result.sort((a, b) {
      bool aDaily = a.session.category.toLowerCase().contains('daily');
      bool bDaily = b.session.category.toLowerCase().contains('daily');

      if (aDaily && !bDaily) return -1; // A Daily, B Weekly -> A dulu
      if (!aDaily && bDaily) return 1;  // A Weekly, B Daily -> B dulu
      
      // Jika sama-sama Daily, urutkan berdasarkan Jam (String sort works for '10.00' vs '16.00')
      if (aDaily && bDaily) {
        return a.session.time.compareTo(b.session.time);
      }
      
      // Jika sama-sama Weekly, urutkan berdasarkan Title atau ID
      return a.session.title.compareTo(b.session.title);
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
                    dailySessionMap: item.dailyMap, // Pass map ID ke kartu
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