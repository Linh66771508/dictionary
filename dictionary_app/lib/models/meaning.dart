// ============================================================================
// Model: Meaning - Một nghĩa của từ
// Dùng theo: Một từ có thể có nhiều nghĩa khác nhau
// ============================================================================

class Meaning {
  final int id; // ID của nghĩa trong database
  final String definition; // Định nghĩa chi tiết
  final int senseOrder; // Thứ tự nghĩa (1, 2, 3, ...)

  Meaning({
    required this.id,
    required this.definition,
    required this.senseOrder,
  });

  // Chuyển đổi từ JSON thành đối tượng Meaning
  factory Meaning.fromJson(Map<String, dynamic> json) {
    return Meaning(
      id: json['id'] as int,
      definition: json['definition'] as String,
      senseOrder:
          json['sense_order'] as int? ?? 0, // Mặc định là 0 nếu không có
    );
  }
}
