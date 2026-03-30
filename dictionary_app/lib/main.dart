// ============================================================================
// File: main.dart - Điểm bắt đầu của ứng dụng TỪ ĐIỂN NGƯỜI DÙNG
// Tác dụng: Khởi chạy ứng dụng, cấu hình giao diện chính
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_screen.dart';

// Hàm main - nơi bắt đầu chạy ứng dụng
void main() {
  runApp(const DictionaryApp());
}

// Lớp DictionaryApp - giao diện chính của ứng dụng từ điển
class DictionaryApp extends StatelessWidget {
  const DictionaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tạo chủ đề (theme) với màu xanh dương
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB)), // Màu xanh dương chính
      useMaterial3: true, // Sử dụng kiểu Material 3 mới
    );

    return MaterialApp(
      title: 'Từ điển Tiếng Việt', // Tên ứng dụng
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.sourceSans3TextTheme(
            baseTheme.textTheme), // Font chữ Source Sans 3
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // Thanh trên màu trắng
          foregroundColor: Colors.black87, // Chữ/icon màu đen
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Màu nền nhạt
      ),
      home: const HomeScreen(), // Màn hình chính của ứng dụng
    );
  }
}
