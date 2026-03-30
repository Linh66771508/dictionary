// ============================================================================
// Model: Synonym - Từ đồng nghĩa
// Dùng theo: Hiển thị những từ có ý nghĩa tương tự
// ============================================================================

class Synonym {
  final int id; // ID của mối quan hệ đồng nghĩa
  final String? word; // Từ gốc
  final String? synonymWord; // Từ đồng nghĩa
  final int? intensity; // Mức độ tương tự (1-5, càng cao càng giống)
  final String? frequency; // Tần suất sử dụng (thường, hiếm, ...)
  final String? note; // Ghi chú thêm

  Synonym({
    required this.id,
    this.word,
    this.synonymWord,
    this.intensity,
    this.frequency,
    this.note,
  });

  // Chuyển đổi từ JSON thành đối tượng Synonym
  factory Synonym.fromJson(Map<String, dynamic> json) {
    return Synonym(
      id: json['id'] as int,
      word: json['word'] as String?,
      synonymWord: json['synonym_word'] as String? ?? json['word'] as String?,
      intensity: json['intensity'] as int?,
      frequency: json['frequency'] as String?,
      note: json['note'] as String?,
    );
  }
}
