/// Model class: Thông tin chi tiết đầy đủ của một từ
///
/// Tác dụng:
///   - Lưu trữ TẤT CẢ thông tin về một từ (không chỉ tóm tắt)
///   - Được dùng khi user click vào một từ để xem/sửa chi tiết
///   - Chứa nested data: meanings, examples, synonyms, proverbs
///   - Từ API endpoint: GET /words/id/{id}
///
/// Dữ liệu (bao gồm):
///   - Thông tin cơ bản: id, word, pronunciation, part_of_speech, ...
///   - Tất cả định nghĩa (meanings)
///   - Tất cả ví dụ (examples)
///   - Tất cả từ đồng nghĩa (synonyms)
///   - Tất cả tục ngữ (proverbs)
///   - Danh sách topic liên quan (topics)
///   - Các từ liên quan (relatedWords)
///
/// So với WordSummary:
///   - WordSummary: ngắn gọn, dùng cho danh sách
///   - WordDetail: đầy đủ, dùng cho chi tiết
///
/// Ví dụ dữ liệu:
///   WordDetail {
///     id: 1,
///     word: "thương",
///     meanings: [Meaning(id: 1, definition: "to love"), ...],
///     examples: [Example(id: 10, exampleText: "Tôi thương..."), ...],
///     synonyms: [Synonym(id: 1, synonymWord: "yêu", intensity: 8), ...],
///     proverbs: [Proverb(id: 1, phrase: "thương người như...", ...), ...]
///   }
///
/// JSON mapping (từ GET /words/id/{id}):
///   - id, word, pronunciation (giữ nguyên)
///   - part_of_speech → partOfSpeech
///   - meanings → List<Meaning> (nested, chuyển đổi từng item)
///   - examples → List<Example>
///   - synonyms → List<Synonym>
///   - proverbs → List<Proverb>
import 'synonym.dart';
import 'proverb.dart';
import 'meaning.dart';
import 'example.dart';

class WordDetail {
  /// ID duy nhất của từ
  /// - Type: int (primary key từ bảng words)
  final int id;

  /// Tên/Chính tả của từ
  /// - Type: String
  /// - Ví dụ: "thương"
  final String word;

  /// Loại từ (optional)
  /// - Type: String?
  /// - Ví dụ: "động từ", "danh từ", "tính từ"
  final String? partOfSpeech;

  /// Cách phát âm (optional)
  /// - Type: String?
  /// - Ví dụ: "thương" (IPA hoặc Việt hóa)
  final String? pronunciation;

  /// Tần suất sử dụng (optional)
  /// - Type: String?
  /// - Ví dụ: "1" (very common), "2" (common), "3" (rare)
  final String? frequency;

  /// Cách dùng/Register (optional)
  /// - Type: String?
  /// - Ví dụ: "formal", "informal", "archaic", "slang"
  final String? register;

  /// Nguồn gốc từ (optional)
  /// - Type: String?
  /// - Ví dụ: "từ Hán", "từ Pháp", "từ gốc Việt"
  final String? etymology;

  /// Tất cả các định nghĩa của từ
  /// - Type: List<Meaning>
  /// - Mỗi từ có thể có nhiều ý nghĩa khác nhau
  /// - Thứ tự theo sense_order (từ 1, 2, 3, ...)
  /// - Ví dụ: [Meaning(id: 1, definition: "to love", senseOrder: 1), ...]
  final List<Meaning> meanings;

  /// Tất cả các ví dụ sử dụng của từ
  /// - Type: List<Example>
  /// - Chứa câu ví dụ thực tế
  /// - Ví dụ: [Example(id: 10, exampleText: "Tôi thương anh ấy"), ...]
  final List<Example> examples;

  /// Tất cả các từ đồng nghĩa
  /// - Type: List<Synonym>
  /// - Chứa các cặp từ có nghĩa giống nhau
  /// - Mỗi synonym có intensity (mức độ tương tự)
  /// - Ví dụ: [Synonym(id: 1, synonymWord: "yêu", intensity: 8), ...]
  final List<Synonym> synonyms;

  /// Tất cả các tục ngữ/thành ngữ liên quan
  /// - Type: List<Proverb>
  /// - Các cụm từ có chứa từ này
  /// - Ví dụ: [Proverb(id: 1, phrase: "thương người như thương thân", ...), ...]
  final List<Proverb> proverbs;

  /// Constructor: Khởi tạo WordDetail
  ///
  /// Tham số (tất cả required):
  ///   - id, word: bắt buộc
  ///   - meanings, examples, synonyms, proverbs: bắt buộc (có thể là list rỗng)
  ///   - Các field khác (pronunciation, frequency, ...): optional
  WordDetail({
    required this.id,
    required this.word,
    this.partOfSpeech,
    this.pronunciation,
    this.frequency,
    this.register,
    this.etymology,
    required this.meanings,
    required this.examples,
    required this.synonyms,
    required this.proverbs,
  });

  /// Factory constructor: Tạo WordDetail từ JSON response của backend
  ///
  /// Tác dụng:
  ///   1. Deserialize JSON từ GET /words/id/{id}
  ///   2. Chuyển đổi nested arrays thành List of objects
  ///   3. Handle null values
  ///
  /// Process:
  ///   1. Extract scalar fields (id, word, pronunciation, ...)
  ///   2. Xử lý meanings array:
  ///      - Lấy json['meanings'] (array of JSON objects)
  ///      - Map qua Meaning.fromJson() cho mỗi item
  ///      - Nếu null → empty list []
  ///   3. Tương tự cho examples, synonyms, proverbs
  ///   4. Return WordDetail instance
  ///
  /// Ví dụ JSON từ API response:
  ///   ```
  ///   {\n    "id": 1,
  ///     "word": "thương",
  ///     "pronunciation": "thương",
  ///     "part_of_speech": "động từ",
  ///     "frequency": "1",\n    "register": "common",
  ///     "etymology": "từ Hán",
  ///     "meanings": [\n      {"id": 1, "definition": "to love", "sense_order": 1},
  ///       {"id": 2, "definition": "to pity", "sense_order": 2}\n    ],
  ///     "examples": [\n      {"id": 10, "example_text": "Tôi thương anh ấy"}\n    ],
  ///     "synonyms": [],\n    "proverbs": []\n  }
  ///   ```
  factory WordDetail.fromJson(Map<String, dynamic> json) {
    return WordDetail(
      id: json['id'] as int,
      word: json['word'] as String,
      partOfSpeech: json['part_of_speech'] as String?,
      pronunciation: json['pronunciation'] as String?,
      frequency: json['frequency'] as String?,
      register: json['register'] as String?,
      etymology: json['etymology'] as String?,

      /// Chuyển đổi meanings array thành List<Meaning>
      /// - json['meanings'] là array of JSON objects
      /// - as List<dynamic>? ?? [] để handle null → empty list
      /// - .map(...).toList() để convert từng item
      meanings: (json['meanings'] as List<dynamic>? ?? [])
          .map((e) => Meaning.fromJson(e as Map<String, dynamic>))
          .toList(),

      /// Tương tự cho examples
      examples: (json['examples'] as List<dynamic>? ?? [])
          .map((e) => Example.fromJson(e as Map<String, dynamic>))
          .toList(),

      /// Tương tự cho synonyms
      synonyms: (json['synonyms'] as List<dynamic>? ?? [])
          .map((e) => Synonym.fromJson(e as Map<String, dynamic>))
          .toList(),

      /// Tương tự cho proverbs
      proverbs: (json['proverbs'] as List<dynamic>? ?? [])
          .map((e) => Proverb.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
