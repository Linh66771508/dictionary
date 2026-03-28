import 'synonym.dart';
import 'proverb.dart';

class WordDetail {
  final int id;
  final String word;
  final String? partOfSpeech;
  final List<String> meanings;
  final List<Synonym> synonyms;
  final List<Proverb> proverbs;

  WordDetail({
    required this.id,
    required this.word,
    this.partOfSpeech,
    required this.meanings,
    required this.synonyms,
    required this.proverbs,
  });

  factory WordDetail.fromJson(Map<String, dynamic> json) {
    return WordDetail(
      id: json['id'] as int,
      word: json['word'] as String,
      partOfSpeech: json['part_of_speech'] as String?,
      meanings: (json['meanings'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      synonyms: (json['synonyms'] as List<dynamic>? ?? [])
          .map((e) => Synonym.fromJson(e as Map<String, dynamic>))
          .toList(),
      proverbs: (json['proverbs'] as List<dynamic>? ?? [])
          .map((e) => Proverb.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
