import 'synonym.dart';
import 'proverb.dart';
import 'meaning.dart';
import 'example.dart';

class WordDetail {
  final int id;
  final String word;
  final String? partOfSpeech;
  final String? pronunciation;
  final String? frequency;
  final String? register;
  final String? etymology;
  final List<Meaning> meanings;
  final List<Example> examples;
  final List<Synonym> synonyms;
  final List<Proverb> proverbs;

  WordDetail({
    required this.id,
    required this.word,
    this.partOfSpeech,
    this.pronunciation,
    this.frequency,
    this.register,
    this.etymology,
    required this.meanings,
    required this.examples,
    required this.synonyms,
    required this.proverbs,
  });

  factory WordDetail.fromJson(Map<String, dynamic> json) {
    return WordDetail(
      id: json['id'] as int,
      word: json['word'] as String,
      partOfSpeech: json['part_of_speech'] as String?,
      pronunciation: json['pronunciation'] as String?,
      frequency: json['frequency'] as String?,
      register: json['register'] as String?,
      etymology: json['etymology'] as String?,
      meanings: (json['meanings'] as List<dynamic>? ?? [])
          .map((e) => Meaning.fromJson(e as Map<String, dynamic>))
          .toList(),
      examples: (json['examples'] as List<dynamic>? ?? [])
          .map((e) => Example.fromJson(e as Map<String, dynamic>))
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
