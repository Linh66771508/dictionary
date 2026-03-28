import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/admin_stats.dart';
import '../models/word_summary.dart';
import '../models/word_detail.dart';
import '../models/synonym.dart';
import '../models/proverb.dart';

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

  Future<void> updateWord(int id, Map<String, dynamic> payload) async {
    final res = await http.put(
      Uri.parse('$baseUrl/admin/words/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200) {
      throw Exception('Update word failed');
    }
  }

  Future<void> addMeaning(int wordId, String definition, {int? senseOrder}) async {
    final payload = {
      'definition': definition,
      if (senseOrder != null) 'sense_order': senseOrder,
    };
    final res = await http.post(
      Uri.parse('$baseUrl/admin/words/$wordId/meanings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200) {
      throw Exception('Add meaning failed');
    }
  }

  Future<void> updateMeaning(int meaningId, {String? definition, int? senseOrder}) async {
    final payload = {
      if (definition != null) 'definition': definition,
      if (senseOrder != null) 'sense_order': senseOrder,
    };
    final res = await http.put(
      Uri.parse('$baseUrl/admin/meanings/$meaningId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200) {
      throw Exception('Update meaning failed');
    }
  }

  Future<void> deleteMeaning(int meaningId) async {
    final res = await http.delete(Uri.parse('$baseUrl/admin/meanings/$meaningId'));
    if (res.statusCode != 200) {
      throw Exception('Delete meaning failed');
    }
  }

  Future<void> addExample(int wordId, String exampleText) async {
    final payload = {'example_text': exampleText};
    final res = await http.post(
      Uri.parse('$baseUrl/admin/words/$wordId/examples'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200) {
      throw Exception('Add example failed');
    }
  }

  Future<void> updateExample(int exampleId, String exampleText) async {
    final payload = {'example_text': exampleText};
    final res = await http.put(
      Uri.parse('$baseUrl/admin/examples/$exampleId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200) {
      throw Exception('Update example failed');
    }
  }

  Future<void> deleteExample(int exampleId) async {
    final res = await http.delete(Uri.parse('$baseUrl/admin/examples/$exampleId'));
    if (res.statusCode != 200) {
      throw Exception('Delete example failed');
    }
  }

  Future<void> addSynonym({
    required int wordId,
    required String synonymWord,
    int? intensity,
    String? frequency,
    String? note,
  }) async {
    final payload = {
      'word': synonymWord,
      if (intensity != null) 'intensity': intensity,
      if (frequency != null) 'frequency': frequency,
      if (note != null) 'note': note,
    };
    final res = await http.post(
      Uri.parse('$baseUrl/admin/synonyms?word_id=$wordId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200) {
      throw Exception('Add synonym failed');
    }
  }

  Future<void> updateSynonym(int synonymId, {String? synonymWord, int? intensity, String? frequency, String? note}) async {
    final payload = {
      if (synonymWord != null) 'synonym_word': synonymWord,
      if (intensity != null) 'intensity': intensity,
      if (frequency != null) 'frequency': frequency,
      if (note != null) 'note': note,
    };
    final res = await http.put(
      Uri.parse('$baseUrl/admin/synonyms/$synonymId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200) {
      throw Exception('Update synonym failed');
    }
  }

  Future<void> deleteSynonym(int synonymId) async {
    final res = await http.delete(Uri.parse('$baseUrl/admin/synonyms/$synonymId'));
    if (res.statusCode != 200) {
      throw Exception('Delete synonym failed');
    }
  }

  Future<List<Synonym>> listSynonyms() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/synonyms'));
    if (res.statusCode != 200) {
      throw Exception('List synonyms failed');
    }
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => Synonym.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> addProverb({
    required int wordId,
    required String phrase,
    String? meaning,
    String? usage,
  }) async {
    final payload = {
      'phrase': phrase,
      if (meaning != null) 'meaning': meaning,
      if (usage != null) 'usage': usage,
    };
    final res = await http.post(
      Uri.parse('$baseUrl/admin/proverbs?word_id=$wordId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200) {
      throw Exception('Add proverb failed');
    }
  }

  Future<void> updateProverb(int proverbId, {String? phrase, String? meaning, String? usage}) async {
    final payload = {
      if (phrase != null) 'phrase': phrase,
      if (meaning != null) 'meaning': meaning,
      if (usage != null) 'usage': usage,
    };
    final res = await http.put(
      Uri.parse('$baseUrl/admin/proverbs/$proverbId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200) {
      throw Exception('Update proverb failed');
    }
  }

  Future<void> deleteProverb(int proverbId) async {
    final res = await http.delete(Uri.parse('$baseUrl/admin/proverbs/$proverbId'));
    if (res.statusCode != 200) {
      throw Exception('Delete proverb failed');
    }
  }

  Future<List<Proverb>> listProverbs() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/proverbs'));
    if (res.statusCode != 200) {
      throw Exception('List proverbs failed');
    }
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => Proverb.fromJson(e as Map<String, dynamic>)).toList();
  }
}
