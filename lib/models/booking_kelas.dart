import 'dart:convert';

// Fungsi bantuan untuk mengubah JSON string menjadi List objek
List<ClassSession> classSessionFromJson(String str) =>
    List<ClassSession>.from(json.decode(str).map((x) => ClassSession.fromJson(x)));

String classSessionToJson(List<ClassSession> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClassSession {
  final int id; // Django models automatically have an id
  final String title;
  final String category;
  final String instructor;
  final int capacityCurrent;
  final int capacityMax;
  final String description;
  final int price;
  final String room;
  final List<String> days; // JSONField di Django menjadi List di Dart
  final String time;

  ClassSession({
    required this.id,
    required this.title,
    required this.category,
    required this.instructor,
    required this.capacityCurrent,
    required this.capacityMax,
    required this.description,
    required this.price,
    required this.room,
    required this.days,
    required this.time,
  });

  // Factory untuk membuat objek dari JSON (mirip dengan yang ada di product.dart)
  factory ClassSession.fromJson(Map<String, dynamic> json) {
    // Cek apakah ada key "fields". Jika ada, gunakan itu. Jika tidak, pakai json langsung.
    var fields = json['fields'] ?? json;
    
    // Ambil ID dari 'pk' (standar Django) atau 'id' (jika custom)
    var idData = json['pk'] ?? json['id'];

    return ClassSession(
      id: idData ?? 0, // Default ke 0 jika null
      title: fields["title"],
      category: fields["category"],
      instructor: fields["instructor"],
      capacityCurrent: fields["capacity_current"],
      capacityMax: fields["capacity_max"],
      description: fields["description"] ?? "",
      price: fields["price"],
      room: fields["room"],
      // Handle List hari
      days: List<String>.from(fields["days"].map((x) => x)),
      time: fields["time"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "category": category,
        "instructor": instructor,
        "capacity_current": capacityCurrent,
        "capacity_max": capacityMax,
        "description": description,
        "price": price,
        "room": room,
        "days": List<dynamic>.from(days.map((x) => x)),
        "time": time,
      };
}

class Booking {
  final int id;
  final int user; // Biasanya API mengembalikan ID user
  final ClassSession session; // Nested object untuk detail sesi kelas
  final String daySelected;
  final bool isCancelled;
  final double priceAtBooking; // DecimalField di Django jadi double
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.user,
    required this.session,
    required this.daySelected,
    required this.isCancelled,
    required this.priceAtBooking,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json["id"],
        user: json["user"], 
        // Asumsi API Anda mengirimkan detail session (nested), 
        // jika hanya ID, ubah tipe data menjadi int.
        session: ClassSession.fromJson(json["session"]),
        daySelected: json["day_selected"] ?? "",
        isCancelled: json["is_cancelled"],
        // Parsing string/number ke double untuk DecimalField
        priceAtBooking: double.parse(json["price_at_booking"].toString()),
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user": user,
        "session": session.toJson(),
        "day_selected": daySelected,
        "is_cancelled": isCancelled,
        "price_at_booking": priceAtBooking,
        "created_at": createdAt.toIso8601String(),
      };
}