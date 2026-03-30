// ============================================================================
// Model: WordDetail - Thông tin đầy đủ của một từ
// Dùng theo: Khi người dùng bấm vào một từ để xem chi tiết
// Chứa TẤT CẢ thông tin: nghĩa, ví dụ, đồng nghĩa, thành ngữ, v.v.
// ============================================================================

import 'topic.dart';
import 'synonym.dart';
import 'proverb.dart';
import 'meaning.dart';
import 'example.dart';

class WordDetail {
  final int id; // ID của từ
  final String word; // Từ tiếng Việt
  final String? pronunciation; // Cách phát âm
  final String? partOfSpeech; // Loại từ (danh từ, động từ, ...)
  final String? frequency; // Tần suất sử dụng (thường, hiếm, ...)
  final String? register; // Mức độ trang trọng (đường dùng, trang trọng, ...)
  final String? etymology; // Nguồn gốc từ (từ đâu?)
  final List<Meaning> meanings; // Danh sách các nghĩa của từ
  final List<Example> examples; // Danh sách ví dụ sử dụng
  final List<Synonym> synonyms; // Danh sách từ đồng nghĩa
  final List<Proverb> proverbs; // Danh sách thành ngữ liên quan
  final List<Topic> topics; // Danh sách chủ đề linh họp
  final List<String> relatedWords; // Danh sách từ liên quan khác

  WordDetail({
    required this.id,
    required this.word,
    this.pronunciation,
    this.partOfSpeech,
    this.frequency,
    this.register,
    this.etymology,
    required this.meanings,
    required this.examples,
    required this.synonyms,
    required this.proverbs,
    required this.topics,
    required this.relatedWords,
  });

  factory WordDetail.fromJson(Map<String, dynamic> json) {
    final meaningList = (json['meanings'] as List<dynamic>? ?? []);
    final exampleList = (json['examples'] as List<dynamic>? ?? []);

    return WordDetail(
      id: json['id'] as int,
      word: json['word'] as String,
      pronunciation: json['pronunciation'] as String?,
      partOfSpeech: json['part_of_speech'] as String?,
      frequency: json['frequency'] as String?,
      register: json['register'] as String?,
      etymology: json['etymology'] as String?,
      meanings: meaningList.asMap().entries.map((entry) {
        final value = entry.value;
        if (value is String) {
          return Meaning(id: 0, definition: value, senseOrder: entry.key + 1);
        }
        if (value is Map<String, dynamic>) {
          return Meaning.fromJson(value);
        }
        return Meaning(
            id: 0, definition: value.toString(), senseOrder: entry.key + 1);
      }).toList(),
      examples: exampleList.map((e) {
        if (e is String) {
          return Example(id: 0, exampleText: e);
        }
        if (e is Map<String, dynamic>) {
          return Example.fromJson(e);
        }
        return Example(id: 0, exampleText: e.toString());
      }).toList(),
      synonyms: (json['synonyms'] as List<dynamic>? ?? [])
          .map((e) => Synonym.fromJson(e as Map<String, dynamic>))
          .toList(),
      proverbs: (json['proverbs'] as List<dynamic>? ?? [])
          .map((e) => Proverb.fromJson(e as Map<String, dynamic>))
          .toList(),
      topics: (json['topics'] as List<dynamic>? ?? [])
          .map((e) => Topic.fromJson(e as Map<String, dynamic>))
          .toList(),
      relatedWords: (json['related_words'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
