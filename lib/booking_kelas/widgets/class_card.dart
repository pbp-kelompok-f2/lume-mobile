import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/auth/screens/login_page.dart'; 
import 'package:lume_mobile/models/booking_kelas.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lume_mobile/checkout/screens/booking_checkout_page.dart';

class ClassCard extends StatelessWidget {
  final ClassSession session;
  final String baseTitle;
  final List<String> daysNames;
  final Map<String, ClassSession> dailySessionMap;
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

    bool isDaily = session.category.toLowerCase() == 'daily';
    bool isWeekly = session.category.toLowerCase() == 'weekly';

    // Warna Card
    const Color cardBg = Color(0xFFE9E3D6);
    const Color borderColor = Color(0xFFCFC8BA);
    const Color textDark = Color(0xFF171717);
    const Color textGray = Color(0xFF374151);
    const Color labelColor = Color(0xFFA8A29E);

    final String priceStr =
        "Rp ${session.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";

    String dayLabel;
    if (isPopular) {
      dayLabel = "Day:";
    } else if (isDaily) {
      dayLabel = "Days to Choose:";
    } else {
      dayLabel = "Days to Attend:";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                        baseTitle,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          text: "By ",
                          style: GoogleFonts.inter(fontSize: 14, color: textGray),
                          children: [
                            TextSpan(
                              text: session.instructor,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF293027),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F4),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, offset: Offset(0, 1)),
                    ],
                  ),
                  child: Text(
                    session.category.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // --- GRID INFO ---
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
                if (isWeekly || isPopular)
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
              dayLabel,
              style: GoogleFonts.inter(color: labelColor, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: daysNames.isNotEmpty
                  ? daysNames.map((d) => _buildDayBadge(d)).toList()
                  : [Text("—", style: GoogleFonts.inter(color: Colors.grey))],
            ),

            const SizedBox(height: 24),
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
        Text(label, style: GoogleFonts.inter(color: labelColor, fontSize: 13)),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildDayBadge(String day) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F4),
        border: Border.all(color: const Color(0xFFD6D3D1)),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Text(
        day,
        style: GoogleFonts.inter(
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
    final ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFD7D6D1),
      foregroundColor: const Color(0xFF5C5B57),
      elevation: 0,
      shadowColor: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFC9C7C0)),
      ),
      textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
    );

    bool isFull = session.capacityCurrent >= session.capacityMax;

    // Helper function untuk cek login sebelum aksi
    void checkAuthAndProceed(VoidCallback action) {
      if (!request.loggedIn) {
        // ✅ Jika belum login, arahkan ke LoginPage
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage(showBack: true,)),
        );
      } else {
        // ✅ Jika sudah login, jalankan aksi (booking/modal)
        action();
      }
    }

    // LOGIKA POPULAR HOME PAGE (Langsung Book)
    if (isPopular && dailySessionMap.length == 1) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isFull
              ? null
              : () {
                  checkAuthAndProceed(() {
                    final sessionToBook = dailySessionMap.values.first;
                    _handleBookingDirectly(context, request, sessionToBook.id);
                  });
                },
          style: style.copyWith(
            backgroundColor: isFull
                ? WidgetStateProperty.all(Colors.grey[300])
                : null,
          ),
          child: Text(isFull ? "Unavailable" : "Book Now"),
        ),
      );
    }

    // LOGIKA CATALOG PAGE (Daily -> Modal)
    if (isDaily) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            checkAuthAndProceed(() {
              _showDaySelectionDialogStyled(context, request);
            });
          },
          style: style,
          child: const Text("Choose Day"),
        ),
      );
    } else {
      // WEEKLY
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isFull
              ? null
              : () {
                  checkAuthAndProceed(() {
                    _handleBooking(context, request, session.id);
                  });
                },
          style: style.copyWith(
            backgroundColor: isFull
                ? WidgetStateProperty.all(Colors.grey[300])
                : null,
          ),
          child: Text(isFull ? "Unavailable" : "Book Now"),
        ),
      );
    }
  }

  // ===========================================================================
  // ✅ MODAL PEMILIHAN HARI (SORTED SENIN-SABTU & STYLED)
  // ===========================================================================
  void _showDaySelectionDialogStyled(BuildContext context, CookieRequest request) {
    final sortedDays = dailySessionMap.keys.toList();
    
    // ✅ Map urutan hari (Support Inggris & Indonesia)
    const dayOrder = {
      'monday': 1, 'senin': 1,
      'tuesday': 2, 'selasa': 2,
      'wednesday': 3, 'rabu': 3,
      'thursday': 4, 'kamis': 4,
      'friday': 5, 'jumat': 5,
      'saturday': 6, 'sabtu': 6,
      'sunday': 7, 'minggu': 7,
    };

    // Sorting Logic
    sortedDays.sort((a, b) {
      int orderA = dayOrder[a.toLowerCase()] ?? 10;
      int orderB = dayOrder[b.toLowerCase()] ?? 10;
      return orderA.compareTo(orderB);
    });

    ClassSession? selectedSession;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
              elevation: 5,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                 decoration: BoxDecoration(
                  color: const Color(0xFFFBF7F5),
                  borderRadius: BorderRadius.circular(18.0),
                  border: Border.all(color: const Color(0xFFE5E0D8)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                          "Select Day",
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2C3028),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.grey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: sortedDays.map((dayName) {
                            final sessionForDay = dailySessionMap[dayName]!;
                            final isSelected = selectedSession == sessionForDay;
                            final isFull = sessionForDay.capacityCurrent >= sessionForDay.capacityMax;

                            return _buildDayOptionCard(
                              dayName: dayName,
                              session: sessionForDay,
                              isSelected: isSelected,
                              isFull: isFull,
                              onTap: () {
                                if (!isFull) {
                                  setState(() {
                                    selectedSession = sessionForDay;
                                  });
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedSession == null
                            ? null
                            : () {
                                Navigator.pop(context);
                                _handleBooking(context, request, selectedSession!.id);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6E7D6B),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          textStyle: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          disabledBackgroundColor: const Color(0xFFA7B29C).withOpacity(0.5),
                        ),
                        child: const Text("Confirm Booking"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDayOptionCard({
    required String dayName,
    required ClassSession session,
    required bool isSelected,
    required bool isFull,
    required VoidCallback onTap,
  }) {
    const Color defaultBg = Color(0xFFF1ECE2);
    const Color selectedBg = Color(0xFFE8E2D6);
    const Color defaultBorder = Color(0xFFCFC8BA);
    const Color selectedBorder = Color(0xFF6E7D6B);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : defaultBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? selectedBorder : defaultBorder,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected ? [
             BoxShadow(
              color: selectedBorder.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dayName, // Nama hari akan tampil di sini
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2C3028),
              ),
            ),
            Text(
              isFull ? "Full" : "${session.capacityCurrent}/${session.capacityMax}",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isFull ? Colors.red[400] : const Color(0xFF6E7D6B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ FUNGSI BARU: Direct Booking (Tanpa Modal) -> Langsung ke Checkout
  Future<void> _handleBookingDirectly(
    BuildContext context,
    CookieRequest request,
    int sessionId,
  ) async {
    try {
      // 1. Kirim Request Booking
      final response = await request.post(
        "http://localhost:8000/bookingkelas/book-flutter/", 
        jsonEncode({"session_id": sessionId}),
      );

      if (context.mounted) {
        if (response['status'] == 'success') {
          // 2. Ambil Booking ID dari response
          final bookingId = response['booking_id'];
          
          // 3. Langsung Pindah ke Halaman Checkout
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingCheckoutPage(bookingId: bookingId),
            ),
          ).then((_) {
             // Refresh halaman ketika user kembali dari checkout (baik sudah bayar atau belum)
             onRefresh(); 
          });

        } else {
          // Jika gagal (misal penuh atau sudah book)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['message'] ?? 'Booking failed',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFF6E7D6B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                'Error: $e',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFF6E7D6B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
        );
      }
    }
  }

  // --- LOGIC: Kirim Request ke Django (Dari Modal) ---
  Future<void> _handleBooking(
    BuildContext context,
    CookieRequest request,
    int sessionId,
  ) async {
    final response = await request.post(
      "http://localhost:8000/bookingkelas/book-flutter/",
      jsonEncode({"session_id": sessionId}),
    );

    if (context.mounted) {
      if (response['status'] == 'success') {
        final bookingId = response['booking_id'];

        // Navigasi ke Checkout juga untuk yang via Modal
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingCheckoutPage(bookingId: bookingId),
            ),
          ).then((_) => onRefresh());

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                response['message'] ?? 'Booking failed',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFF6E7D6B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
        );
      }
    }
  }
}