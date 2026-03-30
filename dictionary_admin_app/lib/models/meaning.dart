/// Model class: Định nghĩa/Nghĩa của một từ
///
/// Tác dụng:
///   - Đại diện cho một định nghĩa của từ
///   - Một từ có thể có nhiều định nghĩa (senses)
///   - Mỗi định nghĩa có thứ tự riêng (sense_order)
///   - Được dùng để hiển thị tất cả các nghĩa của từ
///
/// Dữ liệu:
///   - id: ID duy nhất của định nghĩa (từ bảng word_senses)
///   - definition: Nội dung định nghĩa
///   - senseOrder: Thứ tự hiển thị (1, 2, 3, ...)
///
/// Ví dụ dữ liệu (từ "thương"):
///   - id: 1, definition: "to love", senseOrder: 1
///   - id: 2, definition: "to pity", senseOrder: 2
///
/// JSON mapping:
///   Backend fields → Dart properties:
///   - id → id
///   - definition → definition
///   - sense_order → senseOrder
class Meaning {
  /// ID duy nhất của định nghĩa
  /// - Type: int (primary key từ bảng word_senses)
  final int id;

  /// Nội dung định nghĩa
  /// - Type: String
  /// - Ví dụ: "to love, to have affection for"
  final String definition;

  /// Thứ tự sắp xếp của định nghĩa
  /// - Type: int (1, 2, 3, ...)
  /// - Định nghĩa chính thường là sense_order = 1
  /// - Các nghĩa khác là 2, 3, ...
  final int senseOrder;

  /// Constructor: Khởi tạo Meaning
  ///
  /// Tham số:
  ///   id (required): ID của định nghĩa
  ///   definition (required): Nội dung
  ///   senseOrder (required): Thứ tự hiển thị
  Meaning({
    required this.id,
    required this.definition,
    required this.senseOrder,
  });

  /// Factory constructor: Tạo Meaning từ JSON
  ///
  /// Tác dụng:
  ///   - Deserialize JSON từ API response
  ///   - Chuyển đổi sense_order → senseOrder
  ///   - Handle null với default value 0
  ///
  /// Ví dụ:
  ///   ```
  ///   final json = {"id": 1, "definition": "to love", "sense_order": 1};
  ///   final meaning = Meaning.fromJson(json);
  ///   ```
  factory Meaning.fromJson(Map<String, dynamic> json) {
    return Meaning(
      id: json['id'] as int,
      definition: json['definition'] as String,
      senseOrder: json['sense_order'] as int? ?? 0,
    );
  }
}
