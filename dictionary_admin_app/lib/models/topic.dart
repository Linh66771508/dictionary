/// Model class: Chủ đề/Danh mục từ vựng
///
/// Tác dụng:
///   - Đại diện cho một chủ đề hoặc danh mục từ vựng
///   - Được dùng để phân loại/tổ chức các từ theo chuyên đề
///   - Giúp người dùng dễ tìm kiếm từ liên quan
///
/// Dữ liệu:
///   - id: ID duy nhất của topic
///   - name: Tên topic (bắt buộc)
///   - description: Mô tả topic là gì
///   - icon: Emoji hoặc icon để biểu diễn topic
///   - wordCount: Tổng số từ thuộc topic này
///
/// Ví dụ:
///   Topic {
///     id: 1,
///     name: "Hoạt động hàng ngày",
///     description: "Các từ liên quan đến sinh hoạt hàng ngày",
///     icon: "🏠",
///     wordCount: 25
///   }
///
/// JSON mapping (từ GET /topics):
///   Backend fields → Dart properties:
///   - id → id
///   - name → name
///   - description → description
///   - icon → icon
///   - word_count → wordCount
class Topic {
  /// ID duy nhất của topic
  /// - Type: int (primary key từ bảng topics)
  final int id;

  /// Tên của topic (bắt buộc)
  /// - Type: String
  /// - Ví dụ: "Hoạt động hàng ngày", "Gia đình", "Cảm xúc"
  final String name;

  /// Mô tả chi tiết về topic (optional)
  /// - Type: String?
  /// - Ví dụ: "Các từ liên quan đến sinh hoạt hàng ngày"
  /// - Giúp người dùng hiểu topic này là về cái gì
  final String? description;

  /// Emoji hoặc icon biểu diễn topic (optional)
  /// - Type: String?
  /// - Có thể là emoji: "🏠", "👨‍👩‍👧", "💬"
  /// - Hoặc tên icon: "home", "family", "chat"
  /// - Dùng để hiển thị UI đẹp hơn
  final String? icon;

  /// Tổng số từ thuộc topic này
  /// - Type: int
  /// - Được tính từ bảng word_topics (COUNT(*) GROUP BY topic_id)
  /// - Ví dụ: 25 từ thuộc topic "Hoạt động hàng ngày"
  final int wordCount;

  /// Constructor: Khởi tạo Topic
  ///
  /// Tham số:
  ///   id (required): ID của topic
  ///   name (required): Tên topic
  ///   description (optional): Mô tả
  ///   icon (optional): Icon/emoji
  ///   wordCount (required): Số từ trong topic
  Topic({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.wordCount,
  });

  /// Factory constructor: Tạo Topic từ JSON
  ///
  /// Tác dụng:
  ///   - Deserialize JSON từ API response
  ///   - Chuyển đổi word_count → wordCount
  ///   - Handle null wordCount với default 0
  ///
  /// Ví dụ JSON từ API response:
  ///   ```
  ///   {
  ///     "id": 1,
  ///     "name": "Hoạt động hàng ngày",
  ///     "description": "Các từ về sinh hoạt",
  ///     "icon": "🏠",
  ///     "word_count": 25
  ///   }
  ///   ```
  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      wordCount: json['word_count'] as int? ?? 0,
    );
  }
}
