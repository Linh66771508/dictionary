class AdminStats {
  final int totalWords;
  final int totalSynonyms;
  final int totalProverbs;

  AdminStats({
    required this.totalWords,
    required this.totalSynonyms,
    required this.totalProverbs,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalWords: json['total_words'] as int? ?? 0,
      totalSynonyms: json['total_synonyms'] as int? ?? 0,
      totalProverbs: json['total_proverbs'] as int? ?? 0,
    );
  }
}
