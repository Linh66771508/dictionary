import 'topic.dart';
import 'synonym.dart';
import 'proverb.dart';

class WordDetail {
  final int id;
  final String word;
  final String? pronunciation;
  final String? partOfSpeech;
  final String? frequency;
  final String? register;
  final String? etymology;
  final List<String> meanings;
  final List<String> examples;
  final List<Synonym> synonyms;
  final List<Proverb> proverbs;
  final List<Topic> topics;
  final List<String> relatedWords;

  WordDetail({
    required this.id,
    required this.word,
    this.pronunciation,
    this.partOfSpeech,
    this.frequency,
    this.register,
    this.etymology,
    required this.meanings,
    required this.examples,
    required this.synonyms,
    required this.proverbs,
    required this.topics,
    required this.relatedWords,
  });

  factory WordDetail.fromJson(Map<String, dynamic> json) {
    return WordDetail(
      id: json['id'] as int,
      word: json['word'] as String,
      pronunciation: json['pronunciation'] as String?,
      partOfSpeech: json['part_of_speech'] as String?,
      frequency: json['frequency'] as String?,
      register: json['register'] as String?,
      etymology: json['etymology'] as String?,
      meanings: (json['meanings'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      examples: (json['examples'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      synonyms: (json['synonyms'] as List<dynamic>? ?? [])
          .map((e) => Synonym.fromJson(e as Map<String, dynamic>))
          .toList(),
      proverbs: (json['proverbs'] as List<dynamic>? ?? [])
          .map((e) => Proverb.fromJson(e as Map<String, dynamic>))
          .toList(),
      topics: (json['topics'] as List<dynamic>? ?? [])
          .map((e) => Topic.fromJson(e as Map<String, dynamic>))
          .toList(),
      relatedWords: (json['related_words'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
