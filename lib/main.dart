import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:lume_mobile/theme/lume_colors.dart';

import 'package:lume_mobile/main/screens/main_scaffold.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'Lumé',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: LumeColors.creamBackground,
          colorScheme: ColorScheme.fromSeed(
            seedColor: LumeColors.sageGreen,
            primary: LumeColors.darkText,
            secondary: LumeColors.sageGreen,
            surface: LumeColors.creamBackground,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        // --- GANTI BAGIAN INI ---
        // Gunakan MainScaffold agar Navbar muncul
        home: const MainScaffold(), 
      ),
    );
  }
}