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
  final ApiClient api = ApiClient();
  final TextEditingController searchController = TextEditingController();
  final List<WordSummary> recent = [];
  final List<WordSummary> suggestions = [];
  Timer? debounce;
  bool isBusy = false;
  late Future<List<Topic>> topicsFuture;

  @override
  void initState() {
    super.initState();
    topicsFuture = api.fetchTopics();
  }

  @override
  void dispose() {
    debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void _openWord(WordSummary summary) async {
    final detail = await api.getWordById(summary.id);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WordDetailScreen(detail: detail, onWordTap: _handleRelatedTap),
      ),
    );
  }

  void _handleRelatedTap(String word) async {
    final results = await api.searchWords(word);
    if (!mounted) return;
    if (results.isNotEmpty) {
      _openWord(results.first);
    }
  }

  void _addRecent(WordSummary summary) {
    setState(() {
      recent.removeWhere((w) => w.id == summary.id);
      recent.insert(0, summary);
      if (recent.length > 6) {
        recent.removeLast();
      }
    });
  }

  Future<void> _search() async {
    final query = searchController.text.trim();
    if (query.isEmpty) return;
    setState(() => isBusy = true);
    final results = await api.searchWords(query);
    if (!mounted) return;
    setState(() => isBusy = false);
    if (results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy từ phù hợp.')),
      );
      return;
    }
    final first = results.first;
    _addRecent(first);
    _openWord(first);
  }

  void _openTopic(Topic topic) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TopicScreen(topic: topic, api: api, onWordTap: (word) {
          _addRecent(word);
          _openWord(word);
        }),
      ),
    );
  }

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
                BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 3)),
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
                  title: Text(word.word, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: word.shortDef == null
                      ? null
                      : Text(word.shortDef!, maxLines: 1, overflow: TextOverflow.ellipsis),
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
          BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 4)),
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
                child: const Icon(Icons.schedule, size: 16, color: Color(0xFF4F46E5)),
              ),
              const SizedBox(width: 8),
              const Text('Tìm kiếm gần đây', style: TextStyle(fontWeight: FontWeight.w700)),
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
                      side: BorderSide(color: const Color(0xFFA5B4FC).withOpacity(0.8)),
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
          BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 4)),
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
                child: const Icon(Icons.auto_awesome, size: 16, color: Color(0xFF7C3AED)),
              ),
              const SizedBox(width: 8),
              const Text('Chủ đề', style: TextStyle(fontWeight: FontWeight.w700)),
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
