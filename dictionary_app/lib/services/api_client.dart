import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/topic.dart';
import '../models/word_summary.dart';
import '../models/word_detail.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  Future<List<Topic>> fetchTopics() async {
    final uri = Uri.parse('$baseUrl/topics');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load topics');
    }
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => Topic.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<WordSummary>> searchWords(String query, {int? limit}) async {
    final uri = Uri.parse('$baseUrl/words/search').replace(queryParameters: {
      'q': query,
      if (limit != null) 'limit': limit.toString(),
    });
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Search failed');
    }
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => WordSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<WordDetail> getWordById(int id) async {
    final uri = Uri.parse('$baseUrl/words/id/$id');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Word not found');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return WordDetail.fromJson(data);
  }

  Future<List<WordSummary>> getTopicWords(int topicId) async {
    final uri = Uri.parse('$baseUrl/topics/$topicId/words');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load topic words');
    }
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => WordSummary.fromJson(e as Map<String, dynamic>)).toList();
  }
}
