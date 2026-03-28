class Synonym {
  final int id;
  final int? wordId;
  final String? word;
  final int? synonymWordId;
  final String? synonymWord;
  final int? intensity;
  final String? frequency;
  final String? note;

  Synonym({
    required this.id,
    this.wordId,
    this.word,
    this.synonymWordId,
    this.synonymWord,
    this.intensity,
    this.frequency,
    this.note,
  });

  factory Synonym.fromJson(Map<String, dynamic> json) {
    return Synonym(
      id: json['id'] as int,
      wordId: json['word_id'] as int?,
      word: json['word'] as String?,
      synonymWordId: json['synonym_word_id'] as int?,
      synonymWord: json['synonym_word'] as String?,
      intensity: json['intensity'] as int?,
      frequency: json['frequency'] as String?,
      note: json['note'] as String?,
    );
  }
}
