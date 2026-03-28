class Proverb {
  final int id;
  final String phrase;
  final String? meaning;
  final String? usage;

  Proverb({
    required this.id,
    required this.phrase,
    this.meaning,
    this.usage,
  });

  factory Proverb.fromJson(Map<String, dynamic> json) {
    return Proverb(
      id: json['id'] as int,
      phrase: json['phrase'] as String,
      meaning: json['meaning'] as String?,
      usage: json['usage'] as String?,
    );
  }
}
