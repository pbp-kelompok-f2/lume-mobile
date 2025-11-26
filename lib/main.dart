import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lume_mobile/main/screens/main_scaffold.dart'; 
import 'package:lume_mobile/theme/lume_colors.dart';

void main() {
  runApp(const LumeApp());
}

class LumeApp extends StatelessWidget {
  const LumeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      // Arahkan ke MainScaffold (yang ada navbarnya)
      home: const MainScaffold(), 
    );
  }
}