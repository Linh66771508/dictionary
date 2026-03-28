import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/admin_shell.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Admin - Từ điển Tiếng Việt',
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.sourceSans3TextTheme(baseTheme.textTheme),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      ),
      home: const AdminShell(),
    );
  }
}
