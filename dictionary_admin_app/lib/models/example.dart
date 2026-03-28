class Example {
  final int id;
  final String exampleText;

  Example({
    required this.id,
    required this.exampleText,
  });

  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(
      id: json['id'] as int,
      exampleText: json['example_text'] as String,
    );
  }
}
