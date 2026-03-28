class Topic {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final int wordCount;

  Topic({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.wordCount,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      wordCount: json['word_count'] as int? ?? 0,
    );
  }
}
