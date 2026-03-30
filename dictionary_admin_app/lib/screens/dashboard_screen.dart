// ============================================================================
// FILE: dashboard_screen.dart - TRANG TỔNG QUAN QUẢN TRỊ
// TÁC DỤG: Hiển thị thống kê quan trọng trên một trang
// HIỂN thị:
//   - 📊 Tổng số từ trong từ điển
//   - 🔗 Tổng số quan hệ đồng nghĩa
//   - 📝 Tổng số thành ngữ/tục ngữ
// CÔNG NĂNG: Quản trị viên có thể nhìn một cách nhanh tình trạng từ điển
// ============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/admin_stats.dart';
import '../services/api_client.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /// Flutter API client instance để gọi API backend
  /// - Dùng để fetch thống kê từ GET /admin/stats endpoint
  final ApiClient api = ApiClient();

  /// Future object để lưu trữ async data từ api.fetchStats()
  /// - late: không initialize lúc khai báo, sẽ init trong initState()
  /// - Future<AdminStats>: sẽ trả về AdminStats object từ API
  /// - Dùng bởi FutureBuilder để track async loading states
  late Future<AdminStats> statsFuture;

  /// Lifecycle hook gọi khi widget lần đầu build
  /// Tác dụng:
  ///   1. Gọi super.initState() (bắt buộc)
  ///   2. Khởi tạo biến statsFuture bằng api.fetchStats()
  ///      - Gọi GET /admin/stats từ backend
  ///      - Trả về Future sẽ resolve AdminStats object
  ///      - FutureBuilder theo dõi Future này
  @override
  void initState() {
    super.initState();
    statsFuture = api.fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    /// Build giao diện Dashboard
    /// Layout:
    ///   Padding
    ///   └─ Column
    ///      ├─ Text ("Tổng quan") - Tiêu đề
    ///      ├─ Text (subtitle)
    ///      └─ FutureBuilder
    ///         └─ Wrap (3 stat cards - from left đến right)
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Tiêu đề trang
          /// - Font Merriweather, size 28, bold
          Text('Tổng quan',
              style: GoogleFonts.merriweather(
                  fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),

          /// Subtitle mô tả
          const Text('Bảng điều khiển quản trị từ điển Tiếng Việt.'),
          const SizedBox(height: 20),

          /// FutureBuilder: Async UI pattern để fetch và display data
          /// - future: statsFuture từ initState()
          /// - builder: function rebuild UI khi state thay đổi
          /// - States:
          ///   1. waiting: đang fetch từ API -> show CircularProgressIndicator
          ///   2. hasError: API call thất bại -> show error message
          ///   3. done: API call thành công -> show stats trong cards
          FutureBuilder<AdminStats>(
            future: statsFuture,
            builder: (context, snapshot) {
              /// Kiểm tra trạng thái Future
              if (snapshot.connectionState == ConnectionState.waiting) {
                /// Đang chờ API response -> hiển thị loading spinner
                return const Center(child: CircularProgressIndicator());
              }

              /// Nếu có lỗi trong quá trình fetch
              if (snapshot.hasError) {
                /// API call thất bại -> hiển thị error message
                return const Text('Không tải được thống kê.');
              }

              /// API call thành công
              /// - snapshot.data chứa AdminStats object
              /// - ?? AdminStats(...) là fallback nếu data null
              final stats = snapshot.data ??
                  AdminStats(totalWords: 0, totalSynonyms: 0, totalProverbs: 0);

              /// Wrap: Layout widget để xếp cards từ trái qua phải
              /// - spacing: khoảng cách giữa cards (16px)
              /// - runSpacing: khoảng cách giữa hàng (16px)
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  /// Card 1: Tổng số từ
                  /// - title: 'Tổng số từ'
                  /// - value: từ stats.totalWords
                  /// - icon: menu_book (biểu tượng sách)
                  /// - bg: màu xanh nhạt (background của icon)
                  /// - fg: màu xanh đậm (màu icon)
                  _statCard(
                      'Tổng số từ',
                      stats.totalWords.toString(),
                      Icons.menu_book,
                      const Color(0xFFDBEAFE),
                      const Color(0xFF2563EB)),

                  /// Card 2: Quan hệ từ đồng nghĩa
                  _statCard(
                      'Quan hệ đồng nghĩa',
                      stats.totalSynonyms.toString(),
                      Icons.compare_arrows,
                      const Color(0xFFD1FAE5),
                      const Color(0xFF059669)),

                  /// Card 3: Tục ngữ/Thành ngữ
                  _statCard(
                      'Tục ngữ',
                      stats.totalProverbs.toString(),
                      Icons.article,
                      const Color(0xFFEDE9FE),
                      const Color(0xFF7C3AED)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Helper widget: Hiển thị một stat card
  /// Tham số:
  ///   - title: tiêu đề card (ví dụ: 'Tổng số từ')
  ///   - value: giá trị hiển thị (ví dụ: '5000')
  ///   - icon: icon Material Design (ví dụ: Icons.menu_book)
  ///   - bg: màu nền của icon container
  ///   - fg: màu của icon
  ///
  /// Layout:
  ///   Container (240px width, white background)
  ///   └─ Column
  ///      ├─ Row
  ///      │  ├─ Text (title)
  ///      │  └─ Container với icon
  ///      └─ Text (value - con số lớn)
  Widget _statCard(
      String title, String value, IconData icon, Color bg, Color fg) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header row: title + icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Tiêu đề card
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),

              /// Icon container: icon với background màu
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: bg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: fg),
              ),
            ],
          ),
          const SizedBox(height: 12),

          /// Giá trị: số lớn ở font size 22
          /// Ví dụ: '5000', '8000', '200'
          Text(value,
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
