// ============================================================================
// Widget: TopicCard - Thẻ hiển một chủ đề
// Tác dụng: Hiển thị chủ đề với biểu tượng, tên và số từ
// ============================================================================

import 'package:flutter/material.dart';
import '../models/topic.dart';

class TopicCard extends StatelessWidget {
  final Topic topic; // Dữ liệu chủ đề
  final VoidCallback onTap; // Callback khi người dùng bấm

  const TopicCard({
    super.key,
    required this.topic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Thực hiện callback khi bấm
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            // Biểu tượng emoji của chủ đề
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(topic.icon ?? '\u2728',
                  style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            // Tên và mô tả
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topic.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    topic.description ?? '',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Số từ trong chủ đề
            Text('${topic.wordCount} từ',
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
