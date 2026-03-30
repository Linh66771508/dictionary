/// Model class: Thống kê tổng hợp của từ điển (dành cho Admin Dashboard)
///
/// Tác dụng:
///   - Lưu trữ các con số thống kê từ backend
///   - Hiển thị trong Dashboard để admin theo dõi tình trạng từ điển
///   - Dữ liệu này được fetch từ GET /admin/stats endpoint
///
/// Dữ liệu:
///   - totalWords: Tổng số từ vựng trong từ điển
///   - totalSynonyms: Tổng số quan hệ từ đồng nghĩa
///   - totalProverbs: Tổng số tục ngữ/thành ngữ
///
/// Sử dụng:
///   ```
///   final stats = AdminStats(totalWords: 5000, totalSynonyms: 8000, totalProverbs: 200);
///   final statsFromApi = AdminStats.fromJson(apiResponse);
///   ```
///
/// JSON mapping:
///   Backend fields → Dart properties:
///   - total_words → totalWords
///   - total_synonyms → totalSynonyms
///   - total_proverbs → totalProverbs
class AdminStats {
  /// Tổng số từ vựng trong từ điển
  /// - Type: int
  /// - Ví dụ: 5000 từ
  final int totalWords;

  /// Tổng số quan hệ từ đồng nghĩa (relationship pairs)
  /// - Type: int
  /// - Ví dụ: 8000 cặp từ đồng nghĩa
  /// - Chú ý: 1 từ có thể có nhiều từ đồng nghĩa
  final int totalSynonyms;

  /// Tổng số tục ngữ/thành ngữ trong từ điển
  /// - Type: int
  /// - Ví dụ: 200 tục ngữ
  final int totalProverbs;

  /// Constructor: Khởi tạo AdminStats với các tham số required
  ///
  /// Tham số:
  ///   totalWords (required): Số từ
  ///   totalSynonyms (required): Số quan hệ đồng nghĩa
  ///   totalProverbs (required): Số tục ngữ
  ///
  /// Ví dụ:
  ///   final stats = AdminStats(
  ///     totalWords: 5000,
  ///     totalSynonyms: 8000,
  ///     totalProverbs: 200,
  ///   );
  AdminStats({
    required this.totalWords,
    required this.totalSynonyms,
    required this.totalProverbs,
  });

  /// Factory constructor: Tạo AdminStats từ JSON response của backend
  ///
  /// Tác dụng:
  ///   - Deserialize JSON từ API response
  ///   - Chuyển đổi API field names (snake_case) → Dart property names (camelCase)
  ///   - Handle null values với default value 0
  ///
  /// Tham số:
  ///   json: Map<String, dynamic> từ jsonDecode(apiResponse.body)
  ///
  /// Process:
  ///   1. Lấy giá trị từ json['total_words'], nếu null → default 0
  ///   2. Lấy giá trị từ json['total_synonyms'], nếu null → default 0
  ///   3. Lấy giá trị từ json['total_proverbs'], nếu null → default 0
  ///   4. Return new AdminStats instance
  ///
  /// Ví dụ:
  ///   ```
  ///   final jsonData = {"total_words": 5000, "total_synonyms": 8000, "total_proverbs": 200};
  ///   final stats = AdminStats.fromJson(jsonData);
  ///   // stats.totalWords == 5000
  ///   // stats.totalSynonyms == 8000
  ///   // stats.totalProverbs == 200
  ///   ```
  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalWords: json['total_words'] as int? ?? 0,
      totalSynonyms: json['total_synonyms'] as int? ?? 0,
      totalProverbs: json['total_proverbs'] as int? ?? 0,
    );
  }
}
