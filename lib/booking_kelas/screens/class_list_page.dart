import 'package:flutter/material.dart';
import 'package:lume_mobile/booking_kelas/widgets/class_card.dart';
import 'package:lume_mobile/models/booking_kelas.dart';
import 'package:lume_mobile/widgets/lume_app_bar.dart';
import 'package:lume_mobile/config/api_config.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ProcessedSession {
  final ClassSession session;
  final String baseTitle;
  final Map<String, ClassSession> dailyMap; 
  final Set<String> daysNames;

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
  
  String _getDayName(String dayCode) {
    const map = {
      '0': 'Monday', '1': 'Tuesday', '2': 'Wednesday', 
      '3': 'Thursday', '4': 'Friday', '5': 'Saturday', '6': 'Sunday'
    };
    return map[dayCode] ?? dayCode; 
  }

  String _baseTitle(String title) {
    int lastIndex = title.lastIndexOf(' - ');
    if (lastIndex != -1) {
      return title.substring(0, lastIndex);
    }
    return title;
  }

  Future<List<ProcessedSession>> fetchAndProcessClasses(CookieRequest request) async {
    final response = await request.get(apiPath('/bookingkelas/json/'));
    
    List<ClassSession> allSessions = [];
    if (response is List) {
      for (var d in response) { if (d != null) allSessions.add(ClassSession.fromJson(d)); }
    } else if (response is Map && response['sessions'] != null) {
      for (var d in response['sessions']) { if (d != null) allSessions.add(ClassSession.fromJson(d)); }
    }


    Map<String, ProcessedSession> groups = {};

    for (var s in allSessions) {
      String base = _baseTitle(s.title);
      String groupKey = "${base}_${s.time}_${s.category}";

      List<String> currentDayNames = s.days.map((d) => _getDayName(d.toString())).toList();

      if (!groups.containsKey(groupKey)) {
        groups[groupKey] = ProcessedSession(
          session: s,
          baseTitle: base,
          dailyMap: {},
          daysNames: {},
        );
      }

      final group = groups[groupKey]!;
      
      group.daysNames.addAll(currentDayNames);

      if (s.category.toLowerCase() == 'daily') {
        for (var dayName in currentDayNames) {
           group.dailyMap[dayName] = s;
        }
      } else {

      }
    }

    List<ProcessedSession> result = groups.values.toList();
    
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
      appBar: const LumeAppBar(
        title: "Book A Class",
        showBack: false,
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
                    baseTitle: item.baseTitle, 
                    daysNames: item.daysNames.toList()..sort(), 
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
