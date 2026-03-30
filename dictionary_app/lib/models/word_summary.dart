// ============================================================================
// Model: WordSummary - Thông tin tóm tắt của một từ
// Dùng theo: Khi hiển thị danh sách từ (tìm kiếm, chủ đề, v.v.)
// ============================================================================

class WordSummary {
  final int id; // ID của từ trong database
  final String word; // Từ tiếng Việt
  final String? partOfSpeech; // Loại từ (danh từ, động từ, ...)
  final String? shortDef; // Định nghĩa ngắn của từ

  WordSummary({
    required this.id,
    required this.word,
    this.partOfSpeech,
    this.shortDef,
  });

  /// Khoi tao tu JSON nhan duoc tu server
  ///
  /// Tham so:
  ///   - json: Du lieu JSON tu server (dang Map<String, dynamic>)
  ///
  ///   Vi du JSON tu server:
  ///   {
  ///     "id": 1,
  ///     "word": "yeu",
  ///     "part_of_speech": "dong tu",
  ///     "short_def": "co cam tinh"
  ///   }
  ///
  /// Return: WordSummary - doi tuong Dart da tao
  ///
  /// Cach dung:
  ///   final json = {'id': 1, 'word': 'yeu', 'part_of_speech': null};
  ///   final word = WordSummary.fromJson(json);
  factory WordSummary.fromJson(Map<String, dynamic> json) {
    return WordSummary(
      id: json['id'] as int,
      word: json['word'] as String,
      partOfSpeech: json['part_of_speech'] as String?,
      shortDef: json['short_def'] as String?,
    );
  }
}
