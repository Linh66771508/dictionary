/// Model class: Quan hệ từ đồng nghĩa
///
/// Tác dụng:
///   - Đại diện cho mối quan hệ giữa một từ và các từ đồng nghĩa của nó
///   - Lưu trữ thông tin của cặp từ đồng nghĩa
///   - Có thể chỉnh sửa độ tương tự (intensity) giữa các từ
///
/// Dữ liệu:
///   - id: ID của quan hệ đồng nghĩa
///   - wordId: ID của từ gốc (từ chính)
///   - word: Tên của từ gốc
///   - synonymWordId: ID của từ đồng nghĩa
///   - synonymWord: Tên của từ đồng nghĩa
///   - intensity: Mức độ tương tự (1-10, 10=giống nhất)
///   - frequency: Tần suất sử dụng
///   - note: Ghi chú thêm về sự khác biệt
///
/// Ví dụ:
///   - từ gốc: "thương" (id: 1)
///   - từ đồng nghĩa: "yêu" (id: 2)
///   - intensity: 8 (rất tương tự)
///   - note: "more emotional"
///
/// JSON mapping (từ GET /admin/synonyms):
///   Backend fields → Dart properties:
///   - id → id
///   - word_id → wordId
///   - word → word (tên từ gốc)
///   - synonym_word_id → synonymWordId
///   - synonym_word → synonymWord (tên từ đồng nghĩa)
///   - intensity → intensity
///   - frequency → frequency
///   - note → note
class Synonym {
  /// ID duy nhất của quan hệ đồng nghĩa
  /// - Type: int (primary key từ bảng synonyms)
  final int id;

  /// ID của từ gốc
  /// - Type: int?
  /// - Foreign key đến bảng words
  /// - Optional vì khi fetch từ list synonyms có thể có hoặc không
  final int? wordId;

  /// Tên của từ gốc
  /// - Type: String?
  /// - Ví dụ: "thương"
  /// - Optional vì có thể không fetch từ gốc
  final String? word;

  /// ID của từ đồng nghĩa
  /// - Type: int?
  /// - Foreign key đến bảng words (từ khác)
  final int? synonymWordId;

  /// Tên của từ đồng nghĩa
  /// - Type: String?
  /// - Ví dụ: "yêu", "quý"
  final String? synonymWord;

  /// Mức độ tương tự giữa hai từ (intensity)
  /// - Type: int?
  /// - Scale: 1-10 (10 = giống nhất, 1 = ít giống)
  /// - Ví dụ: "thương" và "yêu" = 8 (rất tương tự)
  final int? intensity;

  /// Tần suất sử dụng của từ đồng nghĩa
  /// - Type: String?
  /// - Ví dụ: "1", "2" (có thể là số hoặc mô tả)
  final String? frequency;

  /// Ghi chú thêm về sự khác biệt
  /// - Type: String?
  /// - Ví dụ: "more emotional", "archaic", "only used in North"
  /// - Giúp admin ghi nhớ tại sao lại coi hai từ là đồng nghĩa
  final String? note;

  /// Constructor: Khởi tạo Synonym
  ///
  /// Tham số:
  ///   id (required): ID quan hệ
  ///   wordId, word, synonymWordId, synonymWord, intensity, frequency, note (optional)
  Synonym({
    required this.id,
    this.wordId,
    this.word,
    this.synonymWordId,
    this.synonymWord,
    this.intensity,
    this.frequency,
    this.note,
  });

  /// Factory constructor: Tạo Synonym từ JSON
  ///
  /// Ví dụ JSON từ API response:
  ///   ```
  ///   {
  ///     "id": 1,
  ///     "word_id": 1,
  ///     "word": "thương",
  ///     "synonym_word_id": 2,
  ///     "synonym_word": "yêu",
  ///     "intensity": 8,
  ///     "frequency": "1",
  ///     "note": "more emotional"
  ///   }
  ///   ```
  factory Synonym.fromJson(Map<String, dynamic> json) {
    return Synonym(
      id: json['id'] as int,
      wordId: json['word_id'] as int?,
      word: json['word'] as String?,
      synonymWordId: json['synonym_word_id'] as int?,
      synonymWord: json['synonym_word'] as String?,
      intensity: json['intensity'] as int?,
      frequency: json['frequency'] as String?,
      note: json['note'] as String?,
    );
  }
}
