/// Model class: Tóm tắt thông tin từ (danh sách từ)
///
/// Tác dụng:
///   - Hiển thị danh sách từ trong admin app (lightweight version)
///   - Chỉ chứa thông tin cơ bản, không chứa meanings/examples/synonyms
///   - Dùng để hiển thị trong list view, search results
///   - Khi user click vào một từ trong list → load WordDetail (chi tiết đầy đủ)
///
/// Dữ liệu:
///   - id: ID của từ
///   - word: Tên từ
///   - partOfSpeech: Loại từ (danh từ, động từ, ...)
///   - shortDef: Định nghĩa ngắn (định nghĩa đầu tiên)
///
/// So với WordDetail:
///   WordSummary: Nhẹ, dùng cho danh sách
///   WordDetail: Nặng, dùng khi xem chi tiết
///
/// Ví dụ:
///   WordSummary {
///     id: 1,
///     word: "thương",
///     partOfSpeech: "động từ",
///     shortDef: "to love, to pity"
///   }
///
/// JSON mapping (từ GET /admin/words):
///   Backend fields → Dart properties:
///   - id → id
///   - word → word
///   - part_of_speech → partOfSpeech
///   - short_def → shortDef (định nghĩa đầu tiên)
class WordSummary {
  /// ID duy nhất của từ
  /// - Type: int (primary key từ bảng words)
  final int id;

  /// Tên/Chính tả của từ (bắt buộc)
  /// - Type: String
  /// - Ví dụ: "thương", "yêu", "vui"
  final String word;

  /// Loại từ (optional)
  /// - Type: String?
  /// - Ví dụ: "động từ", "danh từ", "tính từ", "phó từ"
  /// - Giúp người dùng biết cách sử dụng từ
  final String? partOfSpeech;

  /// Định nghĩa ngắn/Định nghĩa chính (optional)
  /// - Type: String?
  /// - Là định nghĩa đầu tiên (sense_order = 1)
  /// - Ví dụ: "to love, to have affection for"
  /// - Dùng để preview nội dung trong danh sách
  final String? shortDef;

  /// Constructor: Khởi tạo WordSummary
  ///
  /// Tham số:
  ///   id (required): ID của từ
  ///   word (required): Tên từ
  ///   partOfSpeech (optional): Loại từ
  ///   shortDef (optional): Định nghĩa ngắn
  ///
  /// Ví dụ:
  ///   final word = WordSummary(
  ///     id: 1,
  ///     word: "thương",
  ///     partOfSpeech: "động từ",
  ///     shortDef: "to love, to pity",
  ///   );
  WordSummary({
    required this.id,
    required this.word,
    this.partOfSpeech,
    this.shortDef,
  });

  /// Factory constructor: Tạo WordSummary từ JSON
  ///
  /// Tác dụng:
  ///   - Deserialize JSON từ API response (/admin/words)
  ///   - Chuyển đổi snake_case → camelCase
  ///   - part_of_speech → partOfSpeech
  ///   - short_def → shortDef
  ///
  /// Ví dụ JSON từ API response:
  ///   ```
  ///   {
  ///     "id": 1,
  ///     "word": "thương",
  ///     "part_of_speech": "động từ",
  ///     "short_def": "to love, to pity"
  ///   }
  ///   ```
  ///
  /// Usage:
  ///   ```
  ///   final words = jsonDecode(response.body) as List;
  ///   final wordList = words
  ///       .map((w) => WordSummary.fromJson(w))
  ///       .toList();
  ///   ```
  factory WordSummary.fromJson(Map<String, dynamic> json) {
    return WordSummary(
      id: json['id'] as int,
      word: json['word'] as String,
      partOfSpeech: json['part_of_speech'] as String?,
      shortDef: json['short_def'] as String?,
    );
  }
}
