import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lume_mobile/models/booking_kelas.dart';

class ClassCard extends StatelessWidget {
  final ClassSession session;
  final VoidCallback onRefresh;
  // Map ini menyimpan ID sesi untuk setiap hari. Contoh: {'Senin': 1, 'Selasa': 2}
  // Hanya terisi jika tipe kelasnya Daily.
  final Map<String, int>? dailySessionMap;

  const ClassCard({
    super.key,
    required this.session,
    required this.onRefresh,
    this.dailySessionMap,
  });

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    // Cek kategori
    bool isDaily = session.category.toLowerCase().contains('daily');

    // Warna Lume
    const Color textBrown = Color(0xFF5D4037); 
    const Color btnGreen = Color(0xFF6E7D6B);
    const Color cardBg = Colors.white;

    // Tentukan Label Hari
    // Jika Weekly, format list hari jadi string rapi (misal: Mon, Wed, Fri)
    // Jika Daily, hardcode "Monday - Saturday" sesuai request
    String daysDisplay;
    if (isDaily) {
      daysDisplay = "Monday - Saturday";
    } else {
      // Mapping hari angka ke nama pendek untuk weekly
      final dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      daysDisplay = session.days.map((d) {
        int? dayIdx = int.tryParse(d);
        return dayIdx != null && dayIdx < 7 ? dayNames[dayIdx] : d;
      }).join(', ');
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 0, 
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.brown.shade100, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER: Title & Price ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    session.title, // Judul
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textBrown,
                      fontFamily: 'Playfair Display',
                    ),
                  ),
                ),
                Text(
                  "Rp ${session.price}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textBrown,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- MIDDLE: Days Info ---
            Text(
              isDaily ? "Day to Choose :" : "Day to Attend :",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              daysDisplay,
              style: const TextStyle(
                fontSize: 16,
                color: textBrown,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 8),
             Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  session.time,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),

            const Divider(height: 24, color: Colors.black12),

            // --- FOOTER: Description & Action ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 12, 
                          color: Colors.grey, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        session.description.isNotEmpty 
                          ? session.description 
                          : "Join our session for a better you.",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: textBrown,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                
                // TOMBOL BOOKING
                ElevatedButton(
                  onPressed: () {
                    if (isDaily) {
                      _showDaySelectionDialog(context, request);
                    } else {
                      // Weekly langsung pakai ID sesi ini
                      _handleBooking(context, request, session.id);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text("Book Now", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGIC: Modal Pemilihan Hari (Daily) ---
  void _showDaySelectionDialog(BuildContext context, CookieRequest request) {
    // Mapping nama hari di UI ke key yang mungkin ada di dailySessionMap
    // Sesuaikan string ini dengan data 'days' dari backend jika backend kirim nama hari.
    // Jika backend kirim angka (0=Senin), kita mapping manual.
    
    // Asumsi: dailySessionMap kuncinya adalah String angka "0", "1", dst atau nama "Monday"
    // Kita buat list opsi manual untuk UI:
    final List<Map<String, String>> dayOptions = [
      {"label": "Monday", "val": "0"},
      {"label": "Tuesday", "val": "1"},
      {"label": "Wednesday", "val": "2"},
      {"label": "Thursday", "val": "3"},
      {"label": "Friday", "val": "4"},
      {"label": "Saturday", "val": "5"},
    ];

    String? selectedVal;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFBF7F5),
              title: const Text("Select Day", style: TextStyle(color: Color(0xFF5D4037))),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: dayOptions.map((option) {
                    // Cek apakah hari ini tersedia di map sesi?
                    bool isAvailable = dailySessionMap != null && dailySessionMap!.containsKey(option['val']);
                    
                    return RadioListTile<String>(
                      title: Text(
                        option['label']!, 
                        style: TextStyle(
                          color: isAvailable ? const Color(0xFF5D4037) : Colors.grey
                        )
                      ),
                      value: option['val']!,
                      groupValue: selectedVal,
                      activeColor: const Color(0xFF6E7D6B),
                      onChanged: isAvailable ? (value) {
                        setState(() => selectedVal = value);
                      } : null, // Disable jika tidak ada sesi di hari itu
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: selectedVal == null 
                      ? null 
                      : () {
                          // Ambil ID sesi yang sesuai dengan hari yang dipilih
                          int? finalSessionId = dailySessionMap![selectedVal];
                          Navigator.pop(context);
                          if (finalSessionId != null) {
                            _handleBooking(context, request, finalSessionId);
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6E7D6B)),
                  child: const Text("Confirm", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- LOGIC: Kirim Request ke Django ---
  Future<void> _handleBooking(BuildContext context, CookieRequest request, int sessionId) async {
    final response = await request.postJson(
      "http://127.0.0.1:8000/bookingkelas/json/", 
      {"session_id": sessionId},
    );

    if (context.mounted) {
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: const Color(0xFF6E7D6B),
            behavior: SnackBarBehavior.floating,
          ),
        );
        onRefresh(); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}