// ============================================================================
// Model: Example - Ví dụ sử dụng từ
// Dùng theo: Để giúp người dùng hiểu cách dùng từ trong câu
// ============================================================================

class Example {
  final int id; // ID của ví dụ trong database
  final String exampleText; // Câu ví dụ

  Example({
    required this.id,
    required this.exampleText,
  });

  // Chuyển đổi từ JSON thành đối tượng Example
  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(
      id: json['id'] as int,
      exampleText: json['example_text'] as String,
    );
  }
}
