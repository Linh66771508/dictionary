class Synonym {
  final int id;
  final String word;
  final int? intensity;
  final String? frequency;
  final String? note;

  Synonym({
    required this.id,
    required this.word,
    this.intensity,
    this.frequency,
    this.note,
  });

  factory Synonym.fromJson(Map<String, dynamic> json) {
    return Synonym(
      id: json['id'] as int,
      word: json['word'] as String,
      intensity: json['intensity'] as int?,
      frequency: json['frequency'] as String?,
      note: json['note'] as String?,
    );
  }
}
