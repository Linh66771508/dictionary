// ============================================================================
// File: main.dart - Điểm bắt đầu của ứng dụng ADMIN DICTIONARY
// Tác dụng: Khởi chạy ứng dụng, cấu hình giao diện chính
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/admin_shell.dart';

// Hàm main - nơi bắt đầu chạy ứng dụng
void main() {
  runApp(const AdminApp());
}

// Lớp AdminApp - giao diện chính của ứng dụng ADMIN
class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tạo chủ đề (theme) với màu xanh dương
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB)), // Màu xanh dương
      useMaterial3: true, // Sử dụng kiểu Material 3 mới
    );

    return MaterialApp(
      title: 'Admin - Từ điển Tiếng Việt', // Tên ứng dụng
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.sourceSans3TextTheme(
            baseTheme.textTheme), // Font chữ Source Sans 3
        scaffoldBackgroundColor: const Color(0xFFF9FAFB), // Màu nền nhạt
      ),
      home: const AdminShell(), // Màn hình chính của ứng dụng
    );
  }
}
