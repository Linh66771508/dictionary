// ============================================================================
// File: api_client.dart - Liên lạc với máy chủ backend
// Tác dụng: Gọi yêu cầu HTTP đến server để lấy dữ liệu
// ============================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/topic.dart';
import '../models/word_summary.dart';
import '../models/word_detail.dart';

class ApiClient {
  final String
      baseUrl; // Dia chi co so du lieu server (Mac dinh: https://dictionary-q5mo.onrender.com)

  // Khoi tao ApiClient voi dia chi server (tuy chon)
  // Neu khong truyen, se dung dia chi trong AppConfig
  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  /// Lay danh sach TAT CA chu de
  ///
  /// Return: Future<List<Topic>> - danh sach cac chu de
  ///
  /// HTTP: GET /topics
  ///
  /// Xuat le:
  ///   - Exception: Neu server tra ve status code khac 200
  ///
  /// Vi du:
  ///   final topics = await api.fetchTopics();
  ///   print(topics.length); // So chu de
  Future<List<Topic>> fetchTopics() async {
    final uri = Uri.parse('$baseUrl/topics');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      // 200 = thành công, khác = lỗi
      throw Exception('Failed to load topics');
    }
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => Topic.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Tim kiem tu dua tren tu khoa
  ///
  /// Tham so:
  ///   - query: Chu ky tim kiem (vi du: "yeu")
  ///   - limit: So luong ket qua toi da (mac dinh: khong gioi han)
  ///
  /// Return: Future<List<WordSummary>> - danh sach cac tu tim duoc
  ///
  /// HTTP: GET /words/search?q=<query>&limit=<limit>
  ///
  /// Xuat le:
  ///   - Exception: Neu tim kiem that bai
  ///
  /// Vi du:
  ///   final results = await api.searchWords("yeu", limit: 8);
  ///   for (var word in results) {
  ///     print(word.word); // In ten tu
  ///   }
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
    return data
        .map((e) => WordSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Lay thong tin CHI TIET cua mot tu theo ID
  ///
  /// Tham so:
  ///   - id: ID cua tu trong database
  ///
  /// Return: Future<WordDetail> - thong tin day du cua tu
  ///   (bao gom: nhan, phat am, loai tu, cac nghia, vi du, dong nghia, v.v.)
  ///
  /// HTTP: GET /words/id/<id>
  ///
  /// Xuat le:
  ///   - Exception: Neu tu khong ton tai
  ///
  /// Vi du:
  ///   final detail = await api.getWordById(1);
  ///   print(detail.word); // Ten tu
  ///   print(detail.meanings.length); // So nghia
  Future<WordDetail> getWordById(int id) async {
    final uri = Uri.parse('$baseUrl/words/id/$id');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Word not found');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return WordDetail.fromJson(data);
  }

  /// Lay TAT CA cac tu trong mot chu de
  ///
  /// Tham so:
  ///   - topicId: ID cua chu de
  ///
  /// Return: Future<List<WordSummary>> - danh sach cac tu trong chu de
  ///
  /// HTTP: GET /topics/<topicId>/words
  ///
  /// Xuat le:
  ///   - Exception: Neu that bai khi tai du lieu
  ///
  /// Vi du:
  ///   final words = await api.getTopicWords(5); // Chu de ID = 5
  ///   for (var word in words) {
  ///     print(word.word); // In danh sach cac tu
  ///   }
  Future<List<WordSummary>> getTopicWords(int topicId) async {
    final uri = Uri.parse('$baseUrl/topics/$topicId/words');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load topic words');
    }
    final data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => WordSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
