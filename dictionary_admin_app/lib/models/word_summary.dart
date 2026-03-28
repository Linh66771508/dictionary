class WordSummary {
  final int id;
  final String word;
  final String? partOfSpeech;
  final String? shortDef;

  WordSummary({
    required this.id,
    required this.word,
    this.partOfSpeech,
    this.shortDef,
  });

  factory WordSummary.fromJson(Map<String, dynamic> json) {
    return WordSummary(
      id: json['id'] as int,
      word: json['word'] as String,
      partOfSpeech: json['part_of_speech'] as String?,
      shortDef: json['short_def'] as String?,
    );
  }
}
