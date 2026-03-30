// ============================================================================
// Model: Topic - Chủ đề (Ví dụ: "Động vật", "Thực vật", v.v.)
// Dùng theo: Grouping các từ theo chủ đề để dễ tìm kiếm
// ============================================================================

class Topic {
  final int id; // ID của chủ đề
  final String name; // Tên chủ đề
  final String? description; // Mô tả chủ đề
  final String? icon; // Biểu tượng/emoji cho chủ đề
  final int wordCount; // Số từ trong chủ đề này

  Topic({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.wordCount,
  });

  // Chuyển đổi từ JSON thành đối tượng Topic
  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      wordCount: json['word_count'] as int? ?? 0, // Mặc định 0 nếu không có
    );
  }
}
