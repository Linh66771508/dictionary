/// Model class: Ví dụ sử dụng của một từ
///
/// Tác dụng:
///   - Đại diện cho một ví dụ/câu ví dụ của từ
///   - Được dùng để minh họa cách sử dụng từ trong thực tế
///   - Có thể thêm/sửa/xóa qua admin API
///
/// Dữ liệu:
///   - id: ID duy nhất của ví dụ (từ bảng word_examples)
///   - exampleText: Nội dung ví dụ (câu mẫu chứa từ)
///
/// Ví dụ dữ liệu:
///   - id: 10
///   - exampleText: "Tôi thương anh ấy rất nhiều"
///
/// JSON mapping:
///   Backend fields → Dart properties:
///   - id → id (giữ nguyên)
///   - example_text → exampleText
class Example {
  /// ID duy nhất của ví dụ
  /// - Type: int (primary key từ bảng word_examples)
  /// - Được tự động generate bởi cơ sở dữ liệu
  final int id;

  /// Nội dung ví dụ/câu ví dụ
  /// - Type: String
  /// - Chứa từ cần ví dụ
  /// - Ví dụ: "Tôi thương anh ấy", "Bác ơi, anh tôi yêu thương gia đình"
  final String exampleText;

  /// Constructor: Khởi tạo Example với id và exampleText
  ///
  /// Tham số:
  ///   id (required): ID của ví dụ
  ///   exampleText (required): Nội dung ví dụ
  ///
  /// Ví dụ:
  ///   final example = Example(
  ///     id: 10,
  ///     exampleText: "Tôi thương anh ấy",
  ///   );
  Example({
    required this.id,
    required this.exampleText,
  });

  /// Factory constructor: Tạo Example từ JSON response của backend
  ///
  /// Tác dụng:
  ///   - Deserialize JSON từ API response
  ///   - Chuyển đổi field names: example_text → exampleText
  ///   - Casti types: json values → Dart types
  ///
  /// Tham số:
  ///   json: Map<String, dynamic> từ API (ví dụ từ word detail)
  ///
  /// Process:
  ///   1. Lấy id từ json['id'] (ép kiểu int)
  ///   2. Lấy exampleText từ json['example_text'] (ép kiểu String)
  ///   3. Return new Example instance
  ///
  /// Ví dụ:
  ///   ```
  ///   final jsonData = {"id": 10, "example_text": "Tôi thương anh ấy"};
  ///   final example = Example.fromJson(jsonData);
  ///   // example.id == 10
  ///   // example.exampleText == "Tôi thương anh ấy"
  ///   ```
  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(
      id: json['id'] as int,
      exampleText: json['example_text'] as String,
    );
  }
}
