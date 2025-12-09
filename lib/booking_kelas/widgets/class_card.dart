import 'package:flutter/material.dart';
import 'package:lume_mobile/models/booking_kelas.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ClassCard extends StatelessWidget {
  final ClassSession session;
  final String baseTitle; // Judul bersih (tanpa harga)
  final List<String> daysNames; // List nama hari (Monday, Tuesday...)
  final Map<String, int> dailySessionMap; // Map untuk modal Daily
  final VoidCallback onRefresh;
  final bool isPopular;

  const ClassCard({
    super.key,
    required this.session,
    required this.baseTitle,
    required this.daysNames,
    required this.dailySessionMap,
    required this.onRefresh,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    // Cek Kategori
    bool isDaily = session.category.toLowerCase() == 'daily';
    bool isWeekly = session.category.toLowerCase() == 'weekly';

    // Warna dari HTML/CSS
    const Color cardBg = Color(0xFFE9E3D6); // bg-[#E9E3D6]
    const Color borderColor = Color(0xFFCFC8BA); // border-[#CFC8BA]
    const Color textDark = Color(0xFF171717); // text-neutral-900
    const Color textGray = Color(0xFF374151); // text-gray-700
    const Color labelColor = Color(0xFFA8A29E); // text-stone-400

    // Format Harga
    final String priceStr =
        "Rp ${session.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18), // rounded-[18px]
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2), // shadow-md
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // p-4
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        baseTitle, // Menggunakan judul bersih
                        style: const TextStyle(
                          fontSize: 20, // text-[20px]
                          fontWeight: FontWeight.bold,
                          color: textDark,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          text: "By ",
                          style: const TextStyle(fontSize: 14, color: textGray),
                          children: [
                            TextSpan(
                              text: session.instructor,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF293027),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge Category
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F4), // bg-stone-100
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, offset: Offset(0, 1)),
                    ],
                  ),
                  child: Text(
                    session.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // --- GRID INFO (Time, Price, Room, Capacity) ---
            // Menggunakan Wrap/Row simulasi Grid
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem("Time", session.time, labelColor),
                ),
                Expanded(child: _buildInfoItem("Price", priceStr, labelColor)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem("Room", session.room, labelColor),
                ),
                // Capacity hanya muncul jika WEEKLY (sesuai HTML)
                if (isWeekly)
                  Expanded(
                    child: _buildInfoItem(
                      "Capacity",
                      "${session.capacityCurrent}/${session.capacityMax}",
                      labelColor,
                    ),
                  )
                else
                  const Spacer(),
              ],
            ),

            const SizedBox(height: 12),

            // --- DAYS LIST ---
            Text(
              isDaily ? "Days to Choose:" : "Days to Attend:",
              style: const TextStyle(color: labelColor, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: daysNames.isNotEmpty
                  ? daysNames.map((d) => _buildDayBadge(d)).toList()
                  : [const Text("—", style: TextStyle(color: Colors.grey))],
            ),

            const SizedBox(height: 24), // mt-auto pt-4
            // --- BUTTONS ---
            _buildActionButton(context, request, isDaily),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildDayBadge(String day) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F4), // bg-stone-100
        border: Border.all(color: const Color(0xFFD6D3D1)), // border-stone-300
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Text(
        day,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    CookieRequest request,
    bool isDaily,
  ) {
    // Style Button dari HTML
    // bg-[#D7D6D1] border-[#C9C7C0] text-[#5C5B57] hover:bg-[#CECDC8]
    final ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFD7D6D1),
      foregroundColor: const Color(0xFF5C5B57),
      elevation: 0,
      shadowColor: Colors
          .black, // simulasi shadow-[0_1px_0_#0f0f0f] agak susah di flutter exact match
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFC9C7C0)),
      ),
    );

    // Cek Full
    bool isFull = session.capacityCurrent >= session.capacityMax;
    // Logika Web: Weekly yg full -> Unavailable (kecuali daily, daily capacity dicek pas pilih hari)
    // Tapi di HTML, 'Unavailable' cuma muncul di blok 'else' paling bawah (jika tidak daily dan tidak ada instance_id).
    // Kita asumsikan tombol disable jika full untuk weekly.

    if (isDaily) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _showDaySelectionDialog(context, request),
          style: style,
          child: const Text(
            "Choose Day",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      // WEEKLY
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isFull
              ? null
              : () => _handleBooking(context, request, session.id),
          style: style.copyWith(
            backgroundColor: isFull
                ? WidgetStateProperty.all(Colors.grey[300])
                : null,
          ),
          child: Text(
            isFull ? "Unavailable" : "Book Now",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  // --- LOGIC: Modal Pemilihan Hari (Daily) ---
  void _showDaySelectionDialog(BuildContext context, CookieRequest request) {
    // Gunakan daysNames dan dailySessionMap yang sudah di-process di ClassListPage
    // agar opsi yang muncul SESUAI dengan data di database (bukan hardcode Senin-Sabtu semua)

    // Sort urutan hari biar rapi (Senin -> Minggu)
    final sortedDays = dailySessionMap.keys.toList();
    // Logic sorting manual sederhana berdasarkan nama hari
    const dayOrder = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 7,
    };
    sortedDays.sort((a, b) => (dayOrder[a] ?? 10).compareTo(dayOrder[b] ?? 10));

    String? selectedDayName;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFBF7F5),
              title: const Text(
                "Select Day",
                style: TextStyle(color: Color(0xFF5D4037)),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: sortedDays.map((dayName) {
                    return RadioListTile<String>(
                      title: Text(
                        dayName,
                        style: const TextStyle(color: Color(0xFF5D4037)),
                      ),
                      value: dayName,
                      groupValue: selectedDayName,
                      activeColor: const Color(0xFF6E7D6B),
                      onChanged: (value) {
                        setState(() => selectedDayName = value);
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: selectedDayName == null
                      ? null
                      : () {
                          // Ambil ID dari Map
                          int? finalSessionId =
                              dailySessionMap[selectedDayName];
                          Navigator.pop(context);
                          if (finalSessionId != null) {
                            _handleBooking(context, request, finalSessionId);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E7D6B),
                  ),
                  child: const Text(
                    "Confirm",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- LOGIC: Kirim Request ke Django ---
  Future<void> _handleBooking(
    BuildContext context,
    CookieRequest request,
    int sessionId,
  ) async {
    // Sesuaikan URL (localhost / 10.0.2.2)
    final response = await request.postJson(
      "http://127.0.0.1:8000/bookingkelas/book-flutter/",
      {"session_id": sessionId},
    );

    if (context.mounted) {
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: const Color(0xFF6E7D6B),
          ),
        );
        onRefresh();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    }
  }
}
