import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/admin_stats.dart';
import '../models/word_summary.dart';
import '../models/word_detail.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  Future<AdminStats> fetchStats() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/stats'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load stats');
    }
    return AdminStats.fromJson(jsonDecode(res.body));
  }

  Future<List<WordSummary>> listWords({String? query}) async {
    final uri = Uri.parse('$baseUrl/admin/words${query != null && query.isNotEmpty ? '?q=$query' : ''}');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load words');
    }
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => WordSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<WordDetail> getWordDetail(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/words/id/$id'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load word detail');
    }
    return WordDetail.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteWord(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/admin/words/$id'));
    if (res.statusCode != 200) {
      throw Exception('Delete failed');
    }
  }

  Future<void> createWord({
    required String word,
    required String partOfSpeech,
    required List<String> meanings,
    List<String> examples = const [],
  }) async {
    final payload = {
      'word': word,
      'part_of_speech': partOfSpeech,
      'meanings': meanings,
      'examples': examples,
    };
    final res = await http.post(
      Uri.parse('$baseUrl/admin/words'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200) {
      throw Exception('Create failed: ${res.body}');
    }
  }

  Future<void> addSynonym({
    required int wordId,
    required String synonymWord,
    int? intensity,
    String? frequency,
    String? note,
  }) async {
    final query = {
      'word_id': wordId.toString(),
      'synonym_word': synonymWord,
      if (intensity != null) 'intensity': intensity.toString(),
      if (frequency != null && frequency.isNotEmpty) 'frequency': frequency,
      if (note != null && note.isNotEmpty) 'note': note,
    };
    final uri = Uri.parse('$baseUrl/admin/synonyms').replace(queryParameters: query);
    final res = await http.post(uri);
    if (res.statusCode != 200) {
      throw Exception('Add synonym failed');
    }
  }

  Future<void> deleteSynonym(int synonymId) async {
    final res = await http.delete(Uri.parse('$baseUrl/admin/synonyms/$synonymId'));
    if (res.statusCode != 200) {
      throw Exception('Delete synonym failed');
    }
  }

  Future<void> addProverb({
    required int wordId,
    required String phrase,
    String? meaning,
    String? usage,
  }) async {
    final query = {
      'word_id': wordId.toString(),
      'phrase': phrase,
      if (meaning != null && meaning.isNotEmpty) 'meaning': meaning,
      if (usage != null && usage.isNotEmpty) 'usage': usage,
    };
    final uri = Uri.parse('$baseUrl/admin/proverbs').replace(queryParameters: query);
    final res = await http.post(uri);
    if (res.statusCode != 200) {
      throw Exception('Add proverb failed');
    }
  }

  Future<void> deleteProverb(int proverbId) async {
    final res = await http.delete(Uri.parse('$baseUrl/admin/proverbs/$proverbId'));
    if (res.statusCode != 200) {
      throw Exception('Delete proverb failed');
    }
  }
}
