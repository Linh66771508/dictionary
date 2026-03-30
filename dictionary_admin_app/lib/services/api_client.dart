import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/admin_stats.dart';
import '../models/word_summary.dart';
import '../models/word_detail.dart';
import '../models/synonym.dart';
import '../models/proverb.dart';
import '../models/topic.dart';

class ApiClient {
  /// Base URL của backend API server
  /// - Default: AppConfig.apiBaseUrl từ config.dart
  /// - Có thể override bằng parameter constructor
  /// - Ví dụ: 'https://dictionary-api.herokuapp.com'
  final String baseUrl;

  /// Constructor: Khởi tạo ApiClient
  /// Tham số:
  ///   baseUrl (optional): URL server, mặc định là AppConfig.apiBaseUrl
  /// Sử dụng:
  ///   final api = ApiClient();  // dùng default từ config
  ///   final api = ApiClient(baseUrl: 'http://localhost:3000');  // custom URL
  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? AppConfig.apiBaseUrl;

  /// ===== STATS ENDPOINT =====

  /// Lấy thống kê tổng hợp (tổng từ, đồng nghĩa, tục ngữ)
  ///
  /// GET /admin/stats
  ///
  /// Return: AdminStats object chứa:
  ///   - totalWords: Tổng số từ
  ///   - totalSynonyms: Tổng quan hệ đồng nghĩa
  ///   - totalProverbs: Tổng tục ngữ
  ///
  /// Exception: Exception nếu API call thất bại (statusCode != 200)
  Future<AdminStats> fetchStats() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/stats'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load stats');
    }
    return AdminStats.fromJson(jsonDecode(res.body));
  }

  /// ===== WORD ENDPOINTS =====

  /// Lấy danh sách tất cả từ (với tùy chọn tìm kiếm)
  ///
  /// GET /admin/words?q=search_string
  ///
  /// Tham số:
  ///   query (optional): Chuỗi tìm kiếm (LIKE search)
  ///     - Nếu null/empty: lấy tất cả từ
  ///     - Nếu có giá trị: tìm từ chứa string này
  ///
  /// Return: List<WordSummary> (danh sách từ tóm tắt)
  ///   Mỗi item chứa:
  ///   - id: ID của từ
  ///   - word: Tên từ
  ///   - partOfSpeech: Loại từ
  ///   - shortDef: Định nghĩa ngắn (definition đầu tiên)
  ///
  /// Exception: Exception nếu API call thất bại
  Future<List<WordSummary>> listWords({String? query}) async {
    final uri = Uri.parse(
        '$baseUrl/admin/words${query != null && query.isNotEmpty ? '?q=$query' : ''}');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load words');
    }
    final data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => WordSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Lấy thông tin chi tiết của một từ
  ///
  /// GET /words/id/{id}
  ///
  /// Tham số:
  ///   id: ID của từ
  ///
  /// Return: WordDetail object chứa:
  ///   - id, word, pronunciation, part_of_speech, frequency, register, etymology
  ///   - meanings: List của các định nghĩa
  ///   - examples: List của các ví dụ
  ///   - synonyms: List của các từ đồng nghĩa
  ///   - proverbs: List của các tục ngữ liên quan
  ///   - topics: List của các topic
  ///   - relatedWords: List của các từ liên quan
  ///
  /// Exception: Exception nếu từ không tồn tại hoặc API call thất bại
  Future<WordDetail> getWordDetail(int id) async {
    final res = await http.get(Uri.parse('$baseUrl/words/id/$id'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load word detail');
    }
    return WordDetail.fromJson(jsonDecode(res.body));
  }

  /// Xóa một từ
  ///
  /// DELETE /admin/words/{id}
  ///
  /// Tham số:
  ///   id: ID của từ cần xóa
  ///
  /// Tác dụng:
  ///   - Xóa từ từ bảng words
  ///   - Cascade delete đến tất cả dữ liệu liên quan:
  ///     (word_senses, word_examples, synonyms, proverbs, word_topics, related_words)
  ///
  /// Return: void (không return gì)
  ///
  /// Exception: Exception nếu từ không tồn tại hoặc xóa thất bại
  Future<void> deleteWord(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/admin/words/$id'));
    if (res.statusCode != 200) {
      throw Exception('Delete failed');
    }
  }

  /// Tạo một từ mới
  ///
  /// POST /admin/words
  ///
  /// Tham số:
  ///   word (required): Tên từ
  ///   partOfSpeech (required): Loại từ (danh từ, động từ, tính từ, ...)
  ///   meanings (required): List các định nghĩa
  ///   examples (optional): List các ví dụ (default: empty list)
  ///
  /// Request payload:
  ///   {
  ///     "word": "thương",
  ///     "part_of_speech": "động từ",
  ///     "meanings": ["to love", "to pity"],
  ///     "examples": ["Tôi thương anh ấy"]
  ///   }
  ///
  /// Return: void (không return gì, nhưng backend trả về WordDetail)
  ///
  /// Exception: Exception nếu từ đã tồn tại hoặc tạo thất bại
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

  /// Cập nhật thông tin cơ bản của một từ
  ///
  /// PUT /admin/words/{id}
  ///
  /// Tham số:
  ///   id: ID của từ cần cập nhật
  ///   payload: Dictionary chứa các field cần update (optional fields)
  ///
  /// Request payload (partial update):
  ///   {
  ///     "word": "thương",
  ///     "part_of_speech": "động từ",
  ///     "pronunciation": "thương",
  ///     "frequency": "1",
  ///     "register": "common",
  ///     "etymology": "từ Hán"
  ///   }
  ///   Chỉ những field có trong payload sẽ được update
  ///
  /// Return: void (không return gì, nhưng backend trả về WordDetail updated)
  ///
  /// Exception: Exception nếu từ không tồn tại hoặc update thất bại
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

  /// ===== MEANINGS ENDPOINTS =====

  /// Thêm một định nghĩa mới cho một từ
  ///
  /// POST /admin/words/{wordId}/meanings
  ///
  /// Tham số:
  ///   wordId: ID của từ
  ///   definition: Nội dung định nghĩa (required)
  ///   senseOrder (optional): Thứ tự định nghĩa (nếu null -> tự động lấy next order)
  ///
  /// Request payload:
  ///   {
  ///     "definition": "to love, to pity"
  ///   }
  ///
  /// Return: void (backend trả về MeaningOut)
  ///
  /// Exception: Exception nếu từ không tồn tại hoặc thêm thất bại
  Future<void> addMeaning(int wordId, String definition,
      {int? senseOrder}) async {
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

  /// Cập nhật một định nghĩa
  ///
  /// PUT /admin/meanings/{meaningId}
  ///
  /// Tham số:
  ///   meaningId: ID của định nghĩa
  ///   definition (optional): Nội dung mới
  ///   senseOrder (optional): Thứ tự mới
  ///
  /// Return: void
  Future<void> updateMeaning(int meaningId,
      {String? definition, int? senseOrder}) async {
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

  /// Xóa một định nghĩa
  ///
  /// DELETE /admin/meanings/{meaningId}
  Future<void> deleteMeaning(int meaningId) async {
    final res =
        await http.delete(Uri.parse('$baseUrl/admin/meanings/$meaningId'));
    if (res.statusCode != 200) {
      throw Exception('Delete meaning failed');
    }
  }

  /// ===== EXAMPLES ENDPOINTS =====

  /// Thêm một ví dụ mới
  ///
  /// POST /admin/words/{wordId}/examples
  ///
  /// Tham số:
  ///   wordId: ID của từ
  ///   exampleText: Nội dung ví dụ
  ///
  /// Request payload:
  ///   {
  ///     "example_text": "Tôi thương anh ấy"
  ///   }
  ///
  /// Return: void (backend trả về ExampleOut)
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

  /// Cập nhật một ví dụ
  ///
  /// PUT /admin/examples/{exampleId}
  /// Thêm một ví dụ mới
  ///
  /// POST /admin/examples/{exampleId}
  ///
  /// Tham số:
  ///   exampleId: ID của ví dụ cần cập nhật
  ///   exampleText: Nội dung ví dụ mới
  ///
  /// Request payload:
  ///   {
  ///     "example_text": "Tôi thương anh ấy lắm"
  ///   }
  ///
  /// Return: void (backend trả về ExampleOut updated)
  ///
  /// Exception: Exception nếu ví dụ không tồn tại hoặc update thất bại
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

  /// Xóa một ví dụ
  ///
  /// DELETE /admin/examples/{exampleId}
  ///
  /// Tham số:
  ///   exampleId: ID của ví dụ cần xóa
  ///
  /// Tác dụng:
  ///   - Xóa ví dụ từ bảng word_examples
  ///   - Từ không bị ảnh hưởng
  ///
  /// Return: void
  ///
  /// Exception: Exception nếu ví dụ không tồn tại hoặc xóa thất bại
  Future<void> deleteExample(int exampleId) async {
    final res =
        await http.delete(Uri.parse('$baseUrl/admin/examples/$exampleId'));
    if (res.statusCode != 200) {
      throw Exception('Delete example failed');
    }
  }

  /// ===== SYNONYMS ENDPOINTS =====

  /// Thêm một quan hệ từ đồng nghĩa
  ///
  /// POST /admin/synonyms?word_id={wordId}
  ///
  /// Tham số:
  ///   wordId: ID của từ gốc
  ///   synonymWord: Tên từ đồng nghĩa (required)
  ///   intensity (optional): Mức độ tương tự (1-10, mặc định: không set)
  ///     - 10: từ gần như hệt nhau
  ///     - 5: từ có liên hệ vừa phải
  ///     - 1: từ hơi có liên hệ
  ///   frequency (optional): Tần suất sử dụng từ đồng nghĩa này
  ///   note (optional): Ghi chú về sự khác biệt giữa hai từ
  ///
  /// Request payload:
  ///   {
  ///     "word": "yêu",
  ///     "intensity": 8,
  ///     "frequency": "1",
  ///     "note": "yêu dùng cho cảm xúc mạnh mẽ hơn"
  ///   }
  ///
  /// Return: void (backend trả về SynonymOut)
  ///
  /// Exception: Exception nếu từ không tồn tại hoặc thêm thất bại
  ///
  /// Ví dụ:
  ///   addSynonym(
  ///     wordId: 1,  // từ "thương"
  ///     synonymWord: "yêu",
  ///     intensity: 8,
  ///     note: "yêu mạnh mẽ hơn"
  ///   )
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

  /// Cập nhật một quan hệ từ đồng nghĩa
  ///
  /// PUT /admin/synonyms/{synonymId}
  ///
  /// Tham số:
  ///   synonymId: ID của record đồng nghĩa cần cập nhật
  ///   synonymWord (optional): Tên từ đồng nghĩa mới
  ///   intensity (optional): Mức độ tương tự mới (1-10)
  ///   frequency (optional): Tần suất mới
  ///   note (optional): Ghi chú mới
  ///
  /// Request payload (partial update):
  ///   {
  ///     "intensity": 9,
  ///     "note": "corrected description"
  ///   }
  ///   Chỉ những field có trong payload sẽ được update
  ///
  /// Return: void (backend trả về SynonymOut updated)
  ///
  /// Exception: Exception nếu synonym không tồn tại hoặc update thất bại
  ///
  /// Ví dụ:
  ///   updateSynonym(5, intensity: 9, note: "yêu rất tương tự")
  Future<void> updateSynonym(int synonymId,
      {String? synonymWord,
      int? intensity,
      String? frequency,
      String? note}) async {
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

  /// Xóa một quan hệ từ đồng nghĩa
  ///
  /// DELETE /admin/synonyms/{synonymId}
  ///
  /// Tham số:
  ///   synonymId: ID của record đồng nghĩa cần xóa
  ///
  /// Tác dụng:
  ///   - Xóa relationship từ bảng word_synonyms
  ///   - Cả hai từ vẫn tồn tại, chỉ mối quan hệ bị xóa
  ///
  /// Return: void
  ///
  /// Exception: Exception nếu synonym không tồn tại hoặc xóa thất bại
  ///
  /// Ví dụ:
  ///   deleteSynonym(5)  // xóa relationship "thương - yêu"
  Future<void> deleteSynonym(int synonymId) async {
    final res =
        await http.delete(Uri.parse('$baseUrl/admin/synonyms/$synonymId'));
    if (res.statusCode != 200) {
      throw Exception('Delete synonym failed');
    }
  }

  /// Lấy danh sách tất cả quan hệ từ đồng nghĩa
  ///
  /// GET /admin/synonyms
  ///
  /// Return: List<Synonym> (tất cả cặp từ đồng nghĩa)
  ///   Mỗi item chứa:
  ///   - id: ID của relationship
  ///   - wordId, word: Từ gốc
  ///   - synonymWordId, synonymWord: Từ đồng nghĩa
  ///   - intensity: Mức độ tương tự
  ///   - frequency: Tần suất
  ///   - note: Ghi chú
  ///
  /// Exception: Exception nếu API call thất bại
  ///
  /// Ví dụ kết quả:
  ///   [
  ///     Synonym(id: 1, word: "thương", synonymWord: "yêu", intensity: 8),
  ///     Synonym(id: 2, word: "thương", synonymWord: "yêu mến", intensity: 7),
  ///   ]
  Future<List<Synonym>> listSynonyms() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/synonyms'));
    if (res.statusCode != 200) {
      throw Exception('List synonyms failed');
    }
    final data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => Synonym.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// ===== PROVERBS ENDPOINTS =====

  /// Thêm một tục ngữ/thành ngữ mới
  ///
  /// POST /admin/proverbs?word_id={wordId}
  ///
  /// Tham số:
  ///   wordId: ID của từ có liên quan đến tục ngữ
  ///   phrase (required): Câu tục ngữ gốc (không dịch từng chữ)
  ///     - Ví dụ: "thương người như thương thân"
  ///   meaning (optional): Ý nghĩa/dịch toàn bộ câu
  ///     - Ví dụ: "yêu thương người khác như yêu thương chính mình"
  ///   usage (optional): Bối cảnh/tình huống sử dụng
  ///     - Ví dụ: "dùng để nói về tình yêu vô điều kiện"
  ///
  /// Request payload:
  ///   {
  ///     "phrase": "thương người như thương thân",
  ///     "meaning": "yêu thương người khác như chính mình",
  ///     "usage": "nói về tình yêu vô điều kiện"
  ///   }
  ///
  /// Return: void (backend trả về ProverbOut)
  ///
  /// Exception: Exception nếu từ không tồn tại hoặc thêm thất bại
  ///
  /// Ví dụ:
  ///   addProverb(
  ///     wordId: 1,
  ///     phrase: "thương người như thương thân",
  ///     meaning: "yêu thương người khác như chính mình",
  ///     usage: "nói về tình yêu vô điều kiện"
  ///   )
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

  /// Cập nhật một tục ngữ/thành ngữ
  ///
  /// PUT /admin/proverbs/{proverbId}
  ///
  /// Tham số:
  ///   proverbId: ID của tục ngữ cần cập nhật
  ///   phrase (optional): Câu tục ngữ mới
  ///   meaning (optional): Ý nghĩa/dịch mới
  ///   usage (optional): Cách dùng mới
  ///
  /// Request payload (partial update):
  ///   {
  ///     "meaning": "dịch ý nghĩa mới",
  ///     "usage": "bối cảnh sử dụng mới"
  ///   }
  ///   Chỉ những field có trong payload sẽ được update
  ///
  /// Return: void (backend trả về ProverbOut updated)
  ///
  /// Exception: Exception nếu proverb không tồn tại hoặc update thất bại
  ///
  /// Ví dụ:
  ///   updateProverb(10, meaning: "dịch ý nghĩa sửa lại")
  Future<void> updateProverb(int proverbId,
      {String? phrase, String? meaning, String? usage}) async {
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

  /// Xóa một tục ngữ/thành ngữ
  ///
  /// DELETE /admin/proverbs/{proverbId}
  ///
  /// Tham số:
  ///   proverbId: ID của tục ngữ cần xóa
  ///
  /// Tác dụng:
  ///   - Xóa record từ bảng word_proverbs
  ///   - Từ không bị ảnh hưởng
  ///
  /// Return: void
  ///
  /// Exception: Exception nếu proverb không tồn tại hoặc xóa thất bại
  ///
  /// Ví dụ:
  ///   deleteProverb(10)  // xóa tục ngữ có id=10
  Future<void> deleteProverb(int proverbId) async {
    final res =
        await http.delete(Uri.parse('$baseUrl/admin/proverbs/$proverbId'));
    if (res.statusCode != 200) {
      throw Exception('Delete proverb failed');
    }
  }

  /// Lấy danh sách tất cả tục ngữ/thành ngữ
  ///
  /// GET /admin/proverbs
  ///
  /// Return: List<Proverb> (tất cả tục ngữ trong database)
  ///   Mỗi item chứa:
  ///   - id: ID của tục ngữ
  ///   - wordId, word: Từ có liên quan
  ///   - phrase: Câu tục ngữ gốc
  ///   - meaning: Ý nghĩa
  ///   - usage: Cách dùng
  ///
  /// Exception: Exception nếu API call thất bại
  ///
  /// Ví dụ kết quả:
  ///   [
  ///     Proverb(id: 1, word: "thương", phrase: "thương người như thương thân", ...),
  ///     Proverb(id: 2, word: "sống", phrase: "sống lâu mới biết sống", ...),
  ///   ]
  Future<List<Proverb>> listProverbs() async {
    final res = await http.get(Uri.parse('$baseUrl/admin/proverbs'));
    if (res.statusCode != 200) {
      throw Exception('List proverbs failed');
    }
    final data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => Proverb.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// ===== TOPICS ENDPOINTS =====

  /// Lấy danh sách tất cả các chủ đề
  ///
  /// GET /topics
  ///
  /// Return: List<Topic> (tất cả chủ đề/danh mục)
  ///   Mỗi item chứa:
  ///   - id: ID của chủ đề
  ///   - name: Tên chủ đề (ví dụ: "Động vật", "Thực vật")
  ///   - description: Mô tả chi tiết
  ///   - icon: Icon hiển thị (emoji)
  ///   - wordCount: Số từ trong chủ đề (từ word_topics COUNT)
  ///
  /// Exception: Exception nếu API call thất bại
  ///
  /// Ví dụ kết quả:
  ///   [
  ///     Topic(id: 1, name: "Động vật", icon: "🐾", wordCount: 50),
  ///     Topic(id: 2, name: "Thực vật", icon: "🌿", wordCount: 35),
  ///   ]
  Future<List<Topic>> listTopics() async {
    final res = await http.get(Uri.parse('$baseUrl/topics'));
    if (res.statusCode != 200) {
      throw Exception('List topics failed');
    }
    final data = jsonDecode(res.body) as List<dynamic>;
    return data.map((e) => Topic.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Lấy danh sách các từ trong một chủ đề
  ///
  /// GET /topics/{topicId}/words
  ///
  /// Tham số:
  ///   topicId: ID của chủ đề
  ///
  /// Return: List<WordSummary> (tất cả từ thuộc chủ đề này)
  ///   Mỗi item chứa: id, word, partOfSpeech, shortDef
  ///
  /// Exception: Exception nếu chủ đề không tồn tại hoặc API call thất bại
  ///
  /// Ví dụ:
  ///   listTopicWords(1)  // lấy tất cả từ trong "Động vật"
  ///   // Kết quả: ["chó", "mèo", "chim", ...]
  Future<List<WordSummary>> listTopicWords(int topicId) async {
    final res = await http.get(Uri.parse('$baseUrl/topics/$topicId/words'));
    if (res.statusCode != 200) {
      throw Exception('List topic words failed');
    }
    final data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => WordSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Tạo một chủ đề mới
  ///
  /// POST /admin/topics
  ///
  /// Tham số:
  ///   name (required): Tên chủ đề
  ///     - Ví dụ: "Động vật", "Con người", "Thực vật"
  ///   description (optional): Mô tả chi tiết
  ///     - Ví dụ: "Các loài động vật trong tự nhiên"
  ///   icon (optional): Icon hiển thị (emoji)
  ///     - Ví dụ: "🐾", "🌿", "👨‍👩‍👧"
  ///
  /// Request payload:
  ///   {
  ///     "name": "Động vật",
  ///     "description": "Các loài động vật trong tự nhiên",
  ///     "icon": "🐾"
  ///   }
  ///
  /// Return: void (backend trả về TopicOut)
  ///
  /// Exception: Exception nếu tạo thất bại
  ///
  /// Ví dụ:
  ///   createTopic(
  ///     name: "Thực vật",
  ///     description: "Các loài cây trồng",
  ///     icon: "🌿"
  ///   )
  Future<void> createTopic(
      {required String name, String? description, String? icon}) async {
    final payload = {
      'name': name,
      'description': description,
      'icon': icon,
    };
    final res = await http.post(
      Uri.parse('$baseUrl/admin/topics'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode != 200) {
      throw Exception('Create topic failed');
    }
  }

  /// Xóa một chủ đề
  ///
  /// DELETE /admin/topics/{id}
  ///
  /// Tham số:
  ///   id: ID của chủ đề cần xóa
  ///
  /// Tác dụng:
  ///   - Xóa chủ đề từ bảng topics
  ///   - Cascade delete: Xóa tất cả liên quan từ word_topics (nhưng từ vẫn tồn tại)
  ///
  /// Return: void
  ///
  /// Exception: Exception nếu chủ đề không tồn tại hoặc xóa thất bại
  ///
  /// Ví dụ:
  ///   deleteTopic(5)  // xóa chủ đề "Động vật"
  Future<void> deleteTopic(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/admin/topics/$id'));
    if (res.statusCode != 200) {
      throw Exception('Delete topic failed');
    }
  }

  /// ===== WORD-TOPIC RELATIONSHIP ENDPOINTS =====

  /// Thêm một từ vào một chủ đề
  ///
  /// POST /admin/topics/{topicId}/words/{wordId}
  ///
  /// Tham số:
  ///   topicId: ID của chủ đề
  ///   wordId: ID của từ
  ///
  /// Tác dụng:
  ///   - Tạo relationship trong bảng word_topics
  ///   - wordCount của chủ đề sẽ tăng 1
  ///
  /// Return: void (backend trả về message)
  ///
  /// Exception: Exception nếu:
  ///   - Chủ đề hoặc từ không tồn tại
  ///   - Từ đã tồn tại trong chủ đề
  ///   - API call thất bại
  ///
  /// Ví dụ:
  ///   addWordToTopic(1, 50)  // thêm từ id=50 vào chủ đề id=1
  ///   // Nếu chủ đề là "Động vật", từ "chó" được thêm vào
  Future<void> addWordToTopic(int topicId, int wordId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/admin/topics/$topicId/words/$wordId'),
    );
    if (res.statusCode != 200) {
      throw Exception('Add word to topic failed');
    }
  }

  /// Xóa một từ khỏi một chủ đề
  ///
  /// DELETE /admin/topics/{topicId}/words/{wordId}
  ///
  /// Tham số:
  ///   topicId: ID của chủ đề
  ///   wordId: ID của từ
  ///
  /// Tác dụng:
  ///   - Xóa relationship từ bảng word_topics
  ///   - Từ vẫn tồn tại trong database (chỉ xóa liên kết)
  ///   - wordCount của chủ đề sẽ giảm 1
  ///
  /// Return: void (backend trả về message)
  ///
  /// Exception: Exception nếu:
  ///   - Chủ đề hoặc từ không tồn tại
  ///   - Từ không nằm trong chủ đề
  ///   - API call thất bại
  ///
  /// Ví dụ:
  ///   removeWordFromTopic(1, 50)  // xóa từ id=50 khỏi chủ đề id=1
  ///   // Từ "chó" không còn trong "Động vật" nhưng vẫn tồn tại trong database
  Future<void> removeWordFromTopic(int topicId, int wordId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/admin/topics/$topicId/words/$wordId'),
    );
    if (res.statusCode != 200) {
      throw Exception('Remove word from topic failed');
    }
  }
}
