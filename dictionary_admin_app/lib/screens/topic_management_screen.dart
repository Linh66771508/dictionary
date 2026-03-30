// ============================================================================
// FILE: topic_management_screen.dart - TRANG QUẢN LÝ CHỦ ĐỀ
// TÁC DỤG: Quản lý các chủ đề (ví dụ: "Động vật", "Thực vật")
// CHỨC NĂNG:
//   ➕ Thêm chủ đề mới
//   ⬅ Thêm các từ vào chủ đề
//   ✏️ Sửa thông tin chủ đề
//   ✗ Xóa chủ đề hoặc các từ theo chủ đề
// NHÓM HÓA: Giúp người dùng tìm từ dựa theo chủ đề
// ============================================================================

import 'package:flutter/material.dart';

import '../models/topic.dart';
import '../models/word_summary.dart';
import '../services/api_client.dart';

class TopicManagementScreen extends StatefulWidget {
  const TopicManagementScreen({super.key});

  @override
  State<TopicManagementScreen> createState() => _TopicManagementScreenState();
}

class _TopicManagementScreenState extends State<TopicManagementScreen> {
  /// ============================================================================
  /// BIẾN TRẠNG THÁI (State Variables)
  /// ============================================================================

  /// API client để gọi các endpoint backend
  /// - Type: ApiClient
  /// - Dùng để: listTopics(), listTopicWords(), createTopic(), deleteTopic()
  ///           addWordToTopic(), removeWordFromTopic(), listWords()
  final ApiClient api = ApiClient();

  /// TextEditingController cho ô tìm kiếm từ
  /// - Type: TextEditingController
  /// - Dùng để: user nhập từ khóa để tìm từ muốn thêm vào chủ đề
  /// - Ví dụ: user gõ "động" để tìm các từ liên quan "động vật"
  final TextEditingController searchController = TextEditingController();

  /// Danh sách tất cả các chủ đề (topic)
  /// - Type: List<Topic>
  /// - Dùng để: hiển thị trong sidebar bên trái
  /// - Mỗi topic có: id, name, description, icon, wordCount
  /// - Được tải: khi initState hoặc khi user nhấn Refresh
  /// - Ví dụ: [Topic(id: 1, name: "Động vật", wordCount: 50), ...]
  List<Topic> topics = [];

  /// Chủ đề hiện đang được chọn (để quản lý)
  /// - Type: Topic? (nullable)
  /// - Dùng để: biết đang xem/sửa chủ đề nào
  /// - Giá trị: null khi chưa chọn, hoặc Topic object
  /// - Thay đổi: khi user nhấn vào topic trong danh sách
  /// - Ảnh hưởng: hiển thị tên, mô tả, và danh sách từ của chủ đề này
  Topic? selected;

  /// Danh sách các từ trong chủ đề hiện đang chọn
  /// - Type: List<WordSummary>
  /// - Dùng để: hiển thị các từ thuộc về topic (phía dưới danh sách)
  /// - Được tải: khi user chọn topic từ sidebar
  /// - Ví dụ: Nếu chọn "Động vật" → hiển thị ["chó", "mèo", "chim", ...]
  /// - Clear: nếu selected == null
  List<WordSummary> topicWords = [];

  /// Danh sách từ tìm được từ kết quả tìm kiếm
  /// - Type: List<WordSummary>
  /// - Dùng để: hiển thị kết quả tìm kiếm khi user nhập tên từ
  /// - Được tạo: khi user nhập từ khóa và nhấn nút "Tìm"
  /// - Hiển thị: thay thế danh sách topicWords khi không rỗng
  /// - Xóa: khi user nhấn "Xóa tìm" hoặc _clearSearchResults()
  List<WordSummary> searchResults = [];

  /// Cờ để biết có đang loading dữ liệu không
  /// - Type: bool
  /// - Dùng để: hiển thị CircularProgressIndicator khi đang tải
  /// - Giá trị: true khi gọi _loadTopics(), false khi xong
  /// - UI: Nếu loading == true → hiển thị spinner, ngược lại hiển thị danh sách
  bool loading = false;

  /// ============================================================================
  /// LIFECYCLE METHODS
  /// ============================================================================

  /// initState: Khởi tạo state khi screen lần đầu tải
  ///
  /// Tác dụng:
  ///   1. Gọi super.initState()
  ///   2. Load danh sách tất cả các chủ đề từ backend
  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  /// ============================================================================
  /// TOPIC MANAGEMENT METHODS
  /// ============================================================================

  /// _loadTopics: Tải danh sách tất cả các chủ đề từ backend
  ///
  /// Tác dụng:
  ///   1. Set loading = true để hiển thị spinner
  ///   2. Gọi api.listTopics() → GET /admin/topics
  ///   3. Lưu danh sách vào topics state
  ///   4. Nếu chưa có selected topic → chọn topic đầu tiên
  ///   5. Nếu đã có selected → tìm topic trong danh sách mới (để sync)
  ///   6. Gọi _loadTopicWords() để load các từ của topic
  ///   7. Set loading = false khi xong (finally block)
  ///
  /// Error handling:
  ///   - Dùng try...finally để đảm bảo set loading = false ngay cả khi error
  ///   - Check mounted trước setState() để tránh memory leak
  ///
  /// Thời điểm gọi:
  ///   - initState() khi lần đầu load screen
  ///   - Sau _createTopic() để load topic mới thêm
  ///   - Sau _deleteTopic() để xóa topic khỏi danh sách
  Future<void> _loadTopics() async {
    setState(() => loading = true);
    try {
      final data = await api.listTopics();
      if (!mounted) return;
      setState(() {
        topics = data;
        if (selected == null && topics.isNotEmpty) {
          selected = topics.first;
        } else if (selected != null) {
          selected = topics.firstWhere(
            (t) => t.id == selected!.id,
            orElse: () => topics.isNotEmpty ? topics.first : selected!,
          );
        }
      });
      await _loadTopicWords();
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  /// _loadTopicWords: Tải danh sách các từ trong chủ đề hiện tại
  ///
  /// Tác dụng:
  ///   1. Kiểm tra nếu selected == null → set topicWords = []
  ///   2. Gọi api.listTopicWords(selected.id) → GET /admin/topics/{id}/words
  ///   3. Lưu danh sách vào topicWords state
  ///
  /// Tham số:
  ///   - selected.id: ID của chủ đề hiện tại
  ///
  /// Kết quả:
  ///   - Danh sách WordSummary chỉ những từ nghĩa với chủ đề này
  ///   - Ví dụ: chủ đề "Động vật" → ["chó", "mèo", "chim", ...]
  ///
  /// Thời điểm gọi:
  ///   - Sau khi user chọn topic từ sidebar
  ///   - Sau _loadTopics()
  ///   - Sau khi thêm/xóa từ từ chủ đề
  ///
  /// Check mounted:
  ///   - Tránh setState() nếu widget bị destroy
  Future<void> _loadTopicWords() async {
    if (selected == null) {
      setState(() => topicWords = []);
      return;
    }
    final data = await api.listTopicWords(selected!.id);
    if (!mounted) return;
    setState(() => topicWords = data);
  }

  /// _createTopic: Tạo chủ đề mới
  ///
  /// Tác dụng:
  ///   1. Mở dialog có form nhập thông tin chủ đề
  ///   2. User nhập: tên (required), mô tả, icon
  ///   3. Nhấn "Lưu" → gọi API POST /admin/topics
  ///   4. Reload danh sách topics
  ///
  /// Dialog fields:
  ///   - Tên chủ đề: required, ví dụ "Động vật"
  ///   - Mô tả: optional, ví dụ "Các loài động vật trong tự nhiên"
  ///   - Icon: optional, ví dụ emoji "🐾"
  ///
  /// API request:
  ///   - api.createTopic(name: "...", description: "...", icon: "...")
  ///   - description và icon → null nếu trống
  ///
  /// Thời điểm gọi:
  ///   - Khi user nhấn nút "+" trên AppBar
  ///
  /// Ví dụ:
  ///   Tên: "Thực vật"
  ///   Mô tả: "Các loài cây"
  ///   Icon: "🌿"
  ///   → api.createTopic(name: "Thực vật", description: "Các loài cây", icon: "🌿")
  Future<void> _createTopic() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final iconController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thêm chủ đề'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên chủ đề'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                ),
                TextField(
                  controller: iconController,
                  decoration:
                      const InputDecoration(labelText: 'Icon (tùy chọn)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
    if (result == true) {
      await api.createTopic(
        name: nameController.text.trim(),
        description: descController.text.trim().isEmpty
            ? null
            : descController.text.trim(),
        icon: iconController.text.trim().isEmpty
            ? null
            : iconController.text.trim(),
      );
      await _loadTopics();
    }
  }

  /// _deleteTopic: Xóa một chủ đề
  ///
  /// Tác dụng:
  ///   1. Mở dialog xác nhận xóa
  ///   2. Hiển thị tên chủ đề cần xóa
  ///   3. Nếu user nhấn "Xóa" → gọi API DELETE /admin/topics/{id}
  ///   4. Reload danh sách topics
  ///
  /// Tham số:
  ///   - topic: Topic object cần xóa
  ///
  /// Dialog:
  ///   - Hiển thị thông báo yêu cầu xác nhận
  ///   - Nút "Hủy" → đóng dialog, không xóa
  ///   - Nút "Xóa" → gọi API delete
  ///
  /// Thời điểm gọi:
  ///   - Khi user nhấn nút delete (X icon) bên topic item
  ///
  /// Ví dụ:
  ///   topic = Topic(id: 5, name: "Động vật")
  ///   → Bảng: "Bạn có chắc muốn xóa chủ đề \"Động vật\"?"
  ///   → api.deleteTopic(5)
  Future<void> _deleteTopic(Topic topic) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa chủ đề'),
          content: Text('Bạn có chắc muốn xóa chủ đề "${topic.name}"?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xóa')),
          ],
        );
      },
    );
    if (result == true) {
      await api.deleteTopic(topic.id);
      await _loadTopics();
    }
  }

  /// ============================================================================
  /// WORD SEARCH METHODS
  /// ============================================================================

  /// _searchWords: Tìm kiếm từ theo từ khóa
  ///
  /// Tác dụng:
  ///   1. Lấy từ khóa từ searchController
  ///   2. Gọi api.listWords(query: keyword) → GET /words?query=...
  ///   3. Lưu kết quả vào searchResults state
  ///   4. UI sẽ hiển thị kết quả thay vì topicWords
  ///
  /// Tham số:
  ///   - query: Từ khóa tìm kiếm lấy từ searchController
  ///
  /// Kết quả:
  ///   - Danh sách WordSummary phù hợp với từ khóa
  ///   - Ví dụ: query="động" → [động vật, động lực, ...]
  ///
  /// Kiểm tra:
  ///   - Nếu query.trim() rỗng → return (không tìm)
  ///
  /// Thời điểm gọi:
  ///   - Khi user nhấn nút "Tìm"
  ///
  /// Ví dụ:
  ///   User gõ "con" vào searchController
  ///   User nhấn "Tìm"
  ///   → api.listWords(query: "con")
  ///   → searchResults = ["con chó", "con mèo", "con gái", ...]
  ///   → UI hiển thị searchResults
  Future<void> _searchWords() async {
    final query = searchController.text.trim();
    if (query.isEmpty) return;
    final data = await api.listWords(query: query);
    if (!mounted) return;
    setState(() => searchResults = data);
  }

  /// _clearSearchResults: Xóa kết quả tìm kiếm, quay về danh sách topic words
  ///
  /// Tác dụng:
  ///   1. Set searchResults = []
  ///   2. UI sẽ hiển thị lại topicWords thay vì searchResults
  ///   3. Không xóa searchController (user có thể tìm lại)
  ///
  /// Thời điểm gọi:
  ///   - Khi user nhấn nút "Xóa tìm"
  void _clearSearchResults() {
    setState(() => searchResults = []);
  }

  /// ============================================================================
  /// WORD-TOPIC RELATIONSHIP METHODS
  /// ============================================================================

  /// _addWordToTopic: Thêm một từ vào chủ đề hiện tại
  ///
  /// Tác dụng:
  ///   1. Kiểm tra nếu selected == null → return
  ///   2. Gọi api.addWordToTopic(topicId, wordId)
  ///   3. Database: insert vào bảng word_topics
  ///   4. Reload danh sách từ của topic
  ///
  /// Tham số:
  ///   - word: WordSummary object của từ cần thêm
  ///
  /// API call:
  ///   - POST /admin/topics/{topicId}/words/{wordId}
  ///   - selected.id: ID của topic hiện chọn
  ///   - word.id: ID của từ cần thêm
  ///
  /// Kết quả:
  ///   - Từ được thêm vào topic
  ///   - topicWords được reload để hiển thị term mới
  ///   - searchResults vẫn hiển thị (user có thể thêm từ khác)
  ///
  /// Thời điểm gọi:
  ///   - Khi user nhấn nút "+" bên một từ trong search results
  ///
  /// Ví dụ:
  ///   selected = Topic(id: 1, name: "Động vật")
  ///   word = WordSummary(id: 50, word: "chó")
  ///   → api.addWordToTopic(1, 50) → POST /admin/topics/1/words/50
  ///   → topicWords thêm "chó"
  Future<void> _addWordToTopic(WordSummary word) async {
    if (selected == null) return;
    await api.addWordToTopic(selected!.id, word.id);
    await _loadTopicWords();
  }

  /// _removeWordFromTopic: Xóa một từ khỏi chủ đề hiện tại
  ///
  /// Tác dụng:
  ///   1. Kiểm tra nếu selected == null → return
  ///   2. Gọi api.removeWordFromTopic(topicId, wordId)
  ///   3. Database: xóa record từ bảng word_topics
  ///   4. Reload danh sách từ của topic
  ///
  /// Tham số:
  ///   - word: WordSummary object của từ cần xóa
  ///
  /// API call:
  ///   - DELETE /admin/topics/{topicId}/words/{wordId}
  ///   - selected.id: ID của topic hiện chọn
  ///   - word.id: ID của từ cần xóa
  ///
  /// Kết quả:
  ///   - Từ bị xóa khỏi topic (nhưng từ vẫn tồn tại trong database)
  ///   - topicWords được reload (item được xóa khỏi danh sách)
  ///   - wordCount của topic giảm
  ///
  /// Thời điểm gọi:
  ///   - Khi user nhấn nút "-" bên một từ trong topicWords list
  ///
  /// Ví dụ:
  ///   selected = Topic(id: 1, name: "Động vật")
  ///   word = WordSummary(id: 50, word: "chó")
  ///   → api.removeWordFromTopic(1, 50)
  ///   → DELETE /admin/topics/1/words/50
  ///   → topicWords không còn "chó"
  Future<void> _removeWordFromTopic(WordSummary word) async {
    if (selected == null) return;
    await api.removeWordFromTopic(selected!.id, word.id);
    await _loadTopicWords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý chủ đề'),
        actions: [
          IconButton(onPressed: _createTopic, icon: const Icon(Icons.add)),
          IconButton(onPressed: _loadTopics, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 300,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Danh sách chủ đề',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: topics.length,
                          itemBuilder: (context, index) {
                            final topic = topics[index];
                            final isSelected = selected?.id == topic.id;
                            return ListTile(
                              title: Text(topic.name),
                              subtitle: Text('Từ: ${topic.wordCount}'),
                              selected: isSelected,
                              onTap: () async {
                                setState(() => selected = topic);
                                await _loadTopicWords();
                              },
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _deleteTopic(topic),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: selected == null
                ? const Center(child: Text('Chọn một chủ đề để quản lý.'))
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected!.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(selected!.description ?? 'Không có mô tả'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                decoration: const InputDecoration(
                                  labelText: 'Tìm từ để thêm vào chủ đề',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _searchWords,
                              child: const Text('Tìm'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: _clearSearchResults,
                              child: const Text('Xóa tìm'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: searchResults.isNotEmpty
                              ? ListView.builder(
                                  itemCount: searchResults.length,
                                  itemBuilder: (context, index) {
                                    final word = searchResults[index];
                                    return ListTile(
                                      title: Text(word.word),
                                      subtitle: word.shortDef == null
                                          ? null
                                          : Text(word.shortDef!),
                                      trailing: IconButton(
                                        icon: const Icon(
                                            Icons.add_circle_outline),
                                        onPressed: () => _addWordToTopic(word),
                                      ),
                                    );
                                  },
                                )
                              : ListView.builder(
                                  itemCount: topicWords.length,
                                  itemBuilder: (context, index) {
                                    final word = topicWords[index];
                                    return ListTile(
                                      title: Text(word.word),
                                      subtitle: word.shortDef == null
                                          ? null
                                          : Text(word.shortDef!),
                                      trailing: IconButton(
                                        icon: const Icon(
                                            Icons.remove_circle_outline),
                                        onPressed: () =>
                                            _removeWordFromTopic(word),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
