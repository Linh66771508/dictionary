// ============================================================================
// FILE: topic_screen.dart - MÀN HÌNH CHỦNG ĐỀ
// TÁC DỤG: Hiển thị danh sách tất cả các từ trong một chủ đề
// VÍ DỤ: Nếu bấm chủ đề "Động vật", sẽ thấy: chó, mèo, chim, v.v.
// CÓ THỂ: Bấm từ any → xem chi tiết từ đó
// ============================================================================

import 'package:flutter/material.dart';

import '../models/topic.dart';
import '../models/word_summary.dart';
import '../services/api_client.dart';

class TopicScreen extends StatelessWidget {
  final Topic topic;
  final ApiClient api;
  final void Function(WordSummary) onWordTap;

  const TopicScreen({
    super.key,
    required this.topic,
    required this.api,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(topic.name),
      ),
      body: FutureBuilder<List<WordSummary>>(
        future: api.getTopicWords(topic.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Không tải được dữ liệu chủ đề.'));
          }
          final words = snapshot.data ?? [];
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: words.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final word = words[index];
              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: Text(word.word,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(word.shortDef ?? ''),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onWordTap(word),
              );
            },
          );
        },
      ),
    );
  }
}
