import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/word_detail.dart';

class WordDetailScreen extends StatelessWidget {
  final WordDetail detail;
  final void Function(String word) onWordTap;

  const WordDetailScreen({
    super.key,
    required this.detail,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(detail.word),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDBEAFE), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.word,
                  style: GoogleFonts.merriweather(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (detail.pronunciation != null && detail.pronunciation!.isNotEmpty)
                      _tag(detail.pronunciation!),
                    if (detail.partOfSpeech != null && detail.partOfSpeech!.isNotEmpty)
                      _tag(detail.partOfSpeech!),
                    if (detail.frequency != null && detail.frequency!.isNotEmpty)
                      _tag('Tần suất: ${detail.frequency}'),
                    if (detail.register != null && detail.register!.isNotEmpty)
                      _tag('Văn phong: ${detail.register}'),
                  ],
                ),
                if (detail.etymology != null && detail.etymology!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    detail.etymology!,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            title: 'Nghĩa',
            child: Column(
              children: detail.meanings
                  .asMap()
                  .entries
                  .map(
                    (entry) => ListTile(
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundColor: const Color(0xFFDBEAFE),
                        child: Text('${entry.key + 1}', style: const TextStyle(fontSize: 12)),
                      ),
                      title: Text(entry.value.definition),
                    ),
                  )
                  .toList(),
            ),
          ),
          if (detail.examples.isNotEmpty) ...[
            const SizedBox(height: 16),
            _section(
              title: 'Ví dụ',
              child: Column(
                children: detail.examples
                    .map(
                      (ex) => ListTile(
                        leading: const Icon(Icons.format_quote),
                        title: Text(ex.exampleText),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          if (detail.synonyms.isNotEmpty) ...[
            const SizedBox(height: 16),
            _section(
              title: 'Từ đồng nghĩa',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: detail.synonyms
                    .map(
                      (syn) => ActionChip(
                        label: Text(syn.word),
                        onPressed: () => onWordTap(syn.word),
                        backgroundColor: const Color(0xFFECFEFF),
                        labelStyle: const TextStyle(color: Color(0xFF0F766E)),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          if (detail.proverbs.isNotEmpty) ...[
            const SizedBox(height: 16),
            _section(
              title: 'Thành ngữ / Tục ngữ',
              child: Column(
                children: detail.proverbs
                    .map(
                      (p) => ListTile(
                        title: Text(p.phrase, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(p.meaning ?? ''),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          if (detail.relatedWords.isNotEmpty) ...[
            const SizedBox(height: 16),
            _section(
              title: 'Từ liên quan',
              child: Wrap(
                spacing: 8,
                children: detail.relatedWords
                    .map(
                      (w) => ActionChip(
                        label: Text(w),
                        onPressed: () => onWordTap(w),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E7FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF3730A3))),
    );
  }
}
