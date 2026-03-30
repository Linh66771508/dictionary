// ============================================================================
// FILE: home_screen.dart - MÀN HÌNH CHỈ
// TÁC DỤC: Hiển thị danh sách chủ đề, thanh tìm kiếm, từ vừa tra (gần đây)
// NGƯỜI DÙNG SẼ:
//   1. Gõ từ vào thanh tìm kiếm → thấy gợi ý
//   2. Bấm nút "Tra" → xem chi tiết từ
//   3. Bấm chủ đề → xem danh sách từ trong chủ đề đó
// ============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/topic.dart';
import '../models/word_summary.dart';
import '../services/api_client.dart';
import '../widgets/search_bar.dart' as app;
import '../widgets/topic_card.dart';
import 'topic_screen.dart';
import 'word_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ========== CÁC BIẾN QUAN TRỌNG ==========
  final ApiClient api = ApiClient(); // Client gọi API đến backend
  final TextEditingController searchController =
      TextEditingController(); // Quản lý ô input tìm kiếm
  final List<WordSummary> recent = []; // Danh sách từ vừa tra cứu (tối đa 6 từ)
  final List<WordSummary> suggestions = []; // Danh sách gợi ý khi gõ từ
  Timer?
      debounce; // Bộ hẹn giờ - dùng để chờ 350ms rồi mới tìm (tránh gọi API quá nhiều)
  bool isBusy = false; // Trạng thái đang tác (loading)?
  late Future<List<Topic>>
      topicsFuture; // Tương lai danh sách chủ đề từ backend

  @override
  void initState() {
    // Khởi tạo - chạy lần đầu tiên khi widget tạo ra
    super.initState();
    // Gọi API lấy danh sách tất cả chủ đề từ backend
    topicsFuture = api.fetchTopics();
  }

  @override
  void dispose() {
    // Dọn dẹp khi widget bị hủy
    // Huỷ bộ hẹn giờ (nếu có) để tránh chạy sau khi widget không còn
    debounce?.cancel();
    // Giải phóng TextEditingController để tránh memory leak
    searchController.dispose();
    super.dispose();
  }

  /// Mở màn hình chi tiết của một từ
  ///
  /// Tham số:
  ///   - summary: Thông tin tóm tắt của từ (id, word, ...)
  ///
  /// Quy trình:
  ///   1. Gọi API get word ID để lấy chi tiết đầy đủ
  ///   2. Check `mounted` - nếu widget đã bị destroy thì không làm gì
  ///   3. Push (mở) màn hình WordDetailScreen
  ///   4. Truyền callback _handleRelatedTap để xử lý khi bấm từ liên quan
  void _openWord(WordSummary summary) async {
    final detail = await api.getWordById(summary.id);
    if (!mounted) return; // Widget đã bị destroy, không nên update state
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            WordDetailScreen(detail: detail, onWordTap: _handleRelatedTap),
      ),
    );
  }

  /// Xử lý khi người dùng bấm vào từ liên quan trong chi tiết từ
  ///
  /// Tham số:
  ///   - word: Tên từ (chuỗi chữ)
  ///
  /// Quy trình:
  ///   1. Tìm kiếm từ đó (gọi API)
  ///   2. Nếu tìm thấy, lấy kết quả đầu tiên
  ///   3. Mở chi tiết từ đó (gọi _openWord)
  void _handleRelatedTap(String word) async {
    final results = await api.searchWords(word);
    if (!mounted) return;
    if (results.isNotEmpty) {
      _openWord(results.first);
    }
  }

  /// Thêm từ vào danh sách "gần đây" hoặc đưa lên đầu nếu đã có
  ///
  /// Tham số:
  ///   - summary: Từ sẽ thêm vào
  ///
  /// Logic:
  ///   - Xoá từ này nếu đã có (tránh bị trùng)
  ///   - Thêm vào đầu danh sách (vị trí 0)
  ///   - Nếu vượt quá 6 từ, xoá từ cuối cùng
  void _addRecent(WordSummary summary) {
    setState(() {
      recent.removeWhere((w) => w.id == summary.id); // Xoá nếu đã có
      recent.insert(0, summary); // Thêm vào đầu (từ mới nhất)
      if (recent.length > 6) {
        // Giữ tối đa 6 từ
        recent.removeLast();
      }
    });
  }

  /// Thực hiện tìm kiếm từ
  ///
  /// Quy trình:
  ///   1. Lấy text từ ô input, loại bỏ khoảng trắng
  ///   2. Nếu trống, return ngay
  ///   3. Set isBusy = true (hiển thị spinner loading)
  ///   4. Gọi API tìm kiếm
  ///   5. Set isBusy = false (ẩn spinner)
  ///   6. Nếu không tìm thấy, hiển thị thông báo "Không tìm thấy"
  ///   7. Nếu tìm thấy, thêm vào gần đây và mở chi tiết
  Future<void> _search() async {
    final query = searchController.text.trim();
    if (query.isEmpty) return;
    setState(() => isBusy = true); // Hiển thị loading
    final results = await api.searchWords(query);
    if (!mounted) return;
    setState(() => isBusy = false); // Ẩn loading
    if (results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy từ phù hợp.')),
      );
      return;
    }
    final first = results.first;
    _addRecent(first); // Thêm vào danh sách gần đây
    _openWord(first); // Mở chi tiết
  }

  /// Mở danh sách từ trong một chủ đề
  ///
  /// Tham số:
  ///   - topic: Chủ đề sẽ mở
  ///
  /// Quy trình:
  ///   1. Push (mở) TopicScreen
  ///   2. Truyền topic, api client, và callback onWordTap
  ///   3. Callback sẽ thêm từ vào gần đây và mở chi tiết
  void _openTopic(Topic topic) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TopicScreen(
            topic: topic,
            api: api,
            onWordTap: (word) {
              _addRecent(word); // Thêm vào gần đây
              _openWord(word); // Mở chi tiết
            }),
      ),
    );
  }

  /// Xử lý khi người dùng gõ trong ô tìm kiếm
  ///
  /// Tham số:
  ///   - value: Chuỗi text mà người dùng vừa gõ
  ///
  /// Logic Debounce:
  ///   - Mỗi lần gõ (onChange), hủy bộ hẹn giờ cũ (nếu có)
  ///   - Thiết lập bộ hẹn giờ mới 350ms
  ///   - Sau 350ms không có người dùng gõ thêm, mới gọi API tìm kiếm
  ///   - Điều này giúp giảm số lần gọi API (từ 10 lần xuống 1 lần)
  ///
  /// Quy trình:
  ///   1. Nếu ô input trống, xoá danh sách gợi ý
  ///   2. Nếu có text, gọi API searchWords với limit=8
  ///   3. Cập nhật suggestions để hiển thị gợi ý
  void _handleSearchChanged(String value) {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 350), () async {
      final query = value.trim();
      if (query.isEmpty) {
        if (!mounted) return;
        setState(() => suggestions.clear());
        return;
      }
      final results = await api.searchWords(query, limit: 8);
      if (!mounted) return;
      setState(() {
        suggestions
          ..clear()
          ..addAll(results);
      });
    });
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.menu_book, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Từ điển Tiếng Việt',
                  style: GoogleFonts.merriweather(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(Icons.auto_awesome, color: Color(0xFFFCD34D)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Tra cứu từ vựng nhanh chóng và dễ dàng',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        app.SearchBar(
          controller: searchController,
          onSubmit: _search,
          onChanged: _handleSearchChanged,
          onClear: () => setState(() => suggestions.clear()),
          isBusy: isBusy,
        ),
        if (suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFCBD5F5)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 6,
                    offset: Offset(0, 3)),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final word = suggestions[index];
                return ListTile(
                  title: Text(word.word,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: word.shortDef == null
                      ? null
                      : Text(word.shortDef!,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    _addRecent(word);
                    _openWord(word);
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRecent() {
    if (recent.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC7D2FE), width: 2),
        boxShadow: const [
          BoxShadow(
              color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.schedule,
                    size: 16, color: Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 8),
              const Text('Tìm kiếm gần đây',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recent
                .map(
                  (word) => ActionChip(
                    label: Text(word.word),
                    onPressed: () => _openWord(word),
                    backgroundColor: const Color(0xFF6366F1),
                    labelStyle: const TextStyle(color: Colors.white),
                    shape: StadiumBorder(
                      side: BorderSide(
                          color: const Color(0xFFA5B4FC).withOpacity(0.8)),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9D5FF), width: 2),
        boxShadow: const [
          BoxShadow(
              color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome,
                    size: 16, color: Color(0xFF7C3AED)),
              ),
              const SizedBox(width: 8),
              const Text('Chủ đề',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Topic>>(
            future: topicsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return const Text('Không tải được chủ đề.');
              }
              final topics = snapshot.data ?? [];
              if (topics.isEmpty) {
                return const Text('Chưa có chủ đề nào.');
              }
              return Column(
                children: topics
                    .map(
                      (topic) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TopicCard(
                          topic: topic,
                          onTap: () => _openTopic(topic),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F2FF), Color(0xFFF1E5FF), Color(0xFFFFF0F5)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 1000;
              if (isWide) {
                return Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    _buildSearchPanel(),
                                    const SizedBox(height: 16),
                                    _buildRecent(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    _buildTopics(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      color: Colors.white,
                      child: ListView(
                        children: [
                          _buildHeader(),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _buildSearchPanel(),
                                const SizedBox(height: 16),
                                _buildRecent(),
                                const SizedBox(height: 16),
                                _buildTopics(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
