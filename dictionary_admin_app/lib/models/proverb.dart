/// Model class: Tục ngữ/Thành ngữ/Idiom
///
/// Tác dụng:
///   - Lưu trữ thông tin về tục ngữ, thành ngữ, hoặc câu tục ngữ
///   - Các cụm từ có ý nghĩa bản dịch không thể dịch từng chữ một
///   - Liên kết với từ để minh họa ngữ cảnh sử dụng
///
/// Dữ liệu:
///   - id: ID duy nhất của tục ngữ
///   - wordId: ID của từ liên quan
///   - word: Tên của từ liên quan
///   - phrase: Cụm từ/tục ngữ chính (required)
///   - meaning: Ý nghĩa/dịch của tục ngữ
///   - usage: Ngữ cảnh sử dụng hoặc ghi chú thêm
///
/// Ví dụ:
///   - phrase: "thương người như thương thân"
///   - meaning: "to love others like you love yourself"
///   - usage: "used when teaching about compassion and empathy"
///
/// JSON mapping (từ GET /admin/proverbs):
///   Backend fields → Dart properties:
///   - id → id
///   - word_id → wordId
///   - word → word
///   - phrase → phrase
///   - meaning → meaning
///   - usage → usage
class Proverb {
  /// ID duy nhất của tục ngữ
  /// - Type: int (primary key từ bảng proverbs)
  final int id;

  /// ID của từ liên quan
  /// - Type: int?
  /// - Foreign key đến bảng words
  /// - Cho biết tục ngữ này liên quan/chứa từ nào
  final int? wordId;

  /// Tên của từ liên quan
  /// - Type: String?
  /// - Ví dụ: "thương"
  final String? word;

  /// Cụm từ/tục ngữ chính (required)
  /// - Type: String (bắt buộc phải có)
  /// - Ví dụ: "thương người như thương thân"
  /// - Có thể là tục ngữ, thành ngữ, hay idiom
  final String phrase;

  /// Ý nghĩa/Dịch của tục ngữ (optional)
  /// - Type: String?
  /// - Giải thích ý nghĩa của tục ngữ
  /// - Ví dụ: "to love others like you love yourself"
  final String? meaning;

  /// Ngữ cảnh sử dụng (optional)
  /// - Type: String?
  /// - Mô tả khi nào sử dụng tục ngữ này
  /// - Ví dụ: "used when teaching about compassion"
  final String? usage;

  /// Constructor: Khởi tạo Proverb
  ///
  /// Tham số:
  ///   id (required): ID của tục ngữ
  ///   phrase (required): Cụm từ/tục ngữ chính
  ///   wordId, word, meaning, usage (optional): Thông tin bổ sung
  Proverb({
    required this.id,
    this.wordId,
    this.word,
    required this.phrase,
    this.meaning,
    this.usage,
  });

  /// Factory constructor: Tạo Proverb từ JSON
  ///
  /// Ví dụ JSON từ API response:
  ///   ```
  ///   {
  ///     "id": 1,
  ///     "word_id": 1,
  ///     "word": "thương",
  ///     "phrase": "thương người như thương thân",
  ///     "meaning": "to love others like yourself",
  ///     "usage": "about compassion"
  ///   }
  ///   ```
  factory Proverb.fromJson(Map<String, dynamic> json) {
    return Proverb(
      id: json['id'] as int,
      wordId: json['word_id'] as int?,
      word: json['word'] as String?,
      phrase: json['phrase'] as String,
      meaning: json['meaning'] as String?,
      usage: json['usage'] as String?,
    );
  }
}
