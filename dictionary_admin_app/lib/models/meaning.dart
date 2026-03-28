class Meaning {
  final int id;
  final String definition;
  final int senseOrder;

  Meaning({
    required this.id,
    required this.definition,
    required this.senseOrder,
  });

  factory Meaning.fromJson(Map<String, dynamic> json) {
    return Meaning(
      id: json['id'] as int,
      definition: json['definition'] as String,
      senseOrder: json['sense_order'] as int? ?? 0,
    );
  }
}
