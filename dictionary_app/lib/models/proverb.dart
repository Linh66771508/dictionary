// ============================================================================
// Model: Proverb - Thành ngữ/Tục ngữ
// Dùng theo: Các cụm từ, thành ngữ hay dùng liên quan đến từ
// ============================================================================

class Proverb {
  final int id; // ID của thành ngữ
  final String phrase; // Cụm từ/thành ngữ
  final String? meaning; // Ý nghĩa của thành ngữ
  final String? usage; // Cách sử dụng hoặc ngữ cảnh

  Proverb({
    required this.id,
    required this.phrase,
    this.meaning,
    this.usage,
  });

  // Chuyển đổi từ JSON thành đối tượng Proverb
  factory Proverb.fromJson(Map<String, dynamic> json) {
    return Proverb(
      id: json['id'] as int,
      phrase: json['phrase'] as String,
      meaning: json['meaning'] as String?,
      usage: json['usage'] as String?,
    );
  }
}
