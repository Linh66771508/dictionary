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
  final ApiClient api = ApiClient();
  late Future<AdminStats> statsFuture;

  @override
  void initState() {
    super.initState();
    statsFuture = api.fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tổng quan', style: GoogleFonts.merriweather(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Bảng điều khiển quản trị từ điển Tiếng Việt.'),
          const SizedBox(height: 20),
          FutureBuilder<AdminStats>(
            future: statsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Text('Không tải được thống kê.');
              }
              final stats = snapshot.data ?? AdminStats(totalWords: 0, totalSynonyms: 0, totalProverbs: 0);
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _statCard('Tổng số từ', stats.totalWords.toString(), Icons.menu_book, const Color(0xFFDBEAFE), const Color(0xFF2563EB)),
                  _statCard('Quan hệ đồng nghĩa', stats.totalSynonyms.toString(), Icons.compare_arrows, const Color(0xFFD1FAE5), const Color(0xFF059669)),
                  _statCard('Tục ngữ', stats.totalProverbs.toString(), Icons.article, const Color(0xFFEDE9FE), const Color(0xFF7C3AED)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color bg, Color fg) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: fg),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
