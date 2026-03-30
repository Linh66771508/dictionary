// ============================================================================
// FILE: synonym_management_screen.dart - TRANG QUẢN LÝ TỪ ĐỒNG NGHĨA
// TÁC DỤG: Quản lý các mối quan hệ đồng nghĩa giữa các từ
// CHỨC NĂNG:
//   ➕ Thêm từ đồng nghĩa cho một từ
//   ⭐ Định mức độ giống (1-5)
//   📝 Ghi chú về tính chất
//   ✗ Xóa mối quan hệ đồng nghĩa
// ============================================================================

import 'package:flutter/material.dart';

import '../models/synonym.dart';
import '../models/word_summary.dart';
import '../services/api_client.dart';

class SynonymManagementScreen extends StatefulWidget {
  const SynonymManagementScreen({super.key});

  @override
  State<SynonymManagementScreen> createState() =>
      _SynonymManagementScreenState();
}

class _SynonymManagementScreenState extends State<SynonymManagementScreen> {
  /// ============================================================================
  /// BIẾN TRẠNG THÁI (State Variables)
  /// ============================================================================

  /// API client để gọi các endpoint backend
  /// - Type: ApiClient
  /// - Dùng để: listSynonyms(), addSynonym(), updateSynonym(), deleteSynonym()
  /// - Khởi tạo: một instance duy nhất
  final ApiClient api = ApiClient();

  /// Future để tải danh sách tất cả các mối quan hệ đồng nghĩa từ backend
  /// - Gọi từ: api.listSynonyms() → GET /admin/synonyms
  /// - Giá trị trả về: List<Synonym> (tất cả cặp từ đồng nghĩa)
  /// - Dùng trong: FutureBuilder để hiển thị danh sách
  /// - Được cập nhật: khi user nhấn Refresh hay sau CRUD operation
  late Future<List<Synonym>> synonymsFuture;

  /// Future để tải danh sách tất cả các từ (dùng cho dropdown chọn từ gốc)
  /// - Gọi từ: api.listWords() → GET /words
  /// - Giá trị trả về: List<WordSummary> (tất cả từ trong database)
  /// - Dùng trong: DropdownButtonFormField để user chọn từ
  /// - Được cập nhật: khi initState
  late Future<List<WordSummary>> wordsFuture;

  /// Từ hiện đang được chọn (từ gốc)
  /// - Type: WordSummary? (nullable)
  /// - Dùng để: biết từ nào user muốn thêm đồng nghĩa cho
  /// - Giá trị: null khi chưa chọn, WordSummary khi đã chọn từ trong dropdown
  /// - Kiểm tra: _addSynonym() sẽ return nếu selectedWord == null
  WordSummary? selectedWord;

  /// TextEditingController cho input "Từ đồng nghĩa"
  /// - Type: TextEditingController
  /// - Giá trị nhập vào: Tên của từ đó (ví dụ: "yêu" cho "thương")
  /// - Sử dụng: lấy giá trị trong _addSynonym() rồi trim()
  /// - Làm sạch: sau khi submit, gọi .clear()
  final TextEditingController synonymController = TextEditingController();

  /// TextEditingController cho input "Mức độ" (intensity)
  /// - Type: TextEditingController
  /// - Giá trị nhập vào: Số từ 1 đến 10 (mức độ tương tự)
  ///   - 10 = từ gần giống hệt nhau
  ///   - 1 = từ hơi có liên hệ
  /// - Sử dụng: int.tryParse() để chuyển từ string → int
  /// - Làm sạch: sau khi submit, gọi .clear()
  final TextEditingController intensityController = TextEditingController();

  /// TextEditingController cho input "Tần suất" (frequency)
  /// - Type: TextEditingController
  /// - Giá trị nhập vào: Đánh giá tần suất sử dụng "thường" hay "hiếm"
  /// - Sử dụng: giữ nguyên string
  /// - Làm sạch: sau khi submit, gọi .clear()
  final TextEditingController frequencyController = TextEditingController();

  /// TextEditingController cho input "Ghi chú" (note)
  /// - Type: TextEditingController
  /// - Giá trị nhập vào: Text mô tả sự khác biệt giữa hai từ
  /// - Ví dụ: "thương dùng cho tình cảm, yêu dùng cho tình yêu"
  /// - Sử dụng: giữ nguyên string
  /// - Làm sạch: sau khi submit, gọi .clear()
  final TextEditingController noteController = TextEditingController();

  /// ============================================================================
  /// LIFECYCLE METHODS
  /// ============================================================================

  /// initState: Khởi tạo state khi screen lần đầu tải
  ///
  /// Tác dụng:
  ///   1. Gọi super.initState()
  ///   2. Load danh sách đồng nghĩa từ backend
  ///   3. Load danh sách từ cho dropdown
  ///
  /// Process:
  ///   - synonymsFuture = api.listSynonyms() → GET /admin/synonyms
  ///   - wordsFuture = api.listWords() → GET /words
  ///   - Cả hai gọi async nhưng không await (để UI không bị block)
  ///   - FutureBuilder trong build() sẽ xử lý khi data về
  @override
  void initState() {
    super.initState();
    synonymsFuture = api.listSynonyms();
    wordsFuture = api.listWords();
  }

  /// ============================================================================
  /// CRUD METHODS
  /// ============================================================================

  /// _refresh: Làm mới danh sách đồng nghĩa
  ///
  /// Tác dụng:
  ///   - Gọi lại api.listSynonyms() để lấy dữ liệu mới nhất từ backend
  ///   - Gọi setState() để trigger rebuild UI
  ///   - Làm cho FutureBuilder lấy Future mới
  ///
  /// Thời điểm gọi:
  ///   - Sau khi thêm từ đồng nghĩa (_addSynonym)
  ///   - Sau khi sửa từ đồng nghĩa (_editSynonym)
  ///   - Sau khi xóa từ đồng nghĩa (_deleteSynonym)
  ///   - Khi user nhấn nút "Làm mới"
  ///
  /// Ví dụ workflow:
  ///   user nhấp "Thêm" → _addSynonym() call API → _refresh() → UI update
  Future<void> _refresh() async {
    setState(() {
      synonymsFuture = api.listSynonyms();
    });
  }

  /// _addSynonym: Thêm mối quan hệ đồng nghĩa mới
  ///
  /// Tác dụng:
  ///   1. Kiểm tra xem user đã chọn từ gốc (selectedWord) chưa
  ///   2. Lấy tên từ đồng nghĩa từ synonymController
  ///   3. Gọi API POST /admin/synonyms để thêm
  ///   4. Clear tất cả input field
  ///   5. Refresh danh sách
  ///
  /// Tham số:
  ///   - selectedWord.id: ID của từ gốc (ví dụ: "thương")
  ///   - synonymWord: Tên từ đồng nghĩa (ví dụ: "yêu")
  ///   - intensity: Mức độ tương tự (1-10, optional)
  ///   - frequency: Tần suất sử dụng (optional)
  ///   - note: Ghi chú về sự khác biệt (optional)
  ///
  /// Kiểm tra validation:
  ///   - Nếu selectedWord == null → return (không làm gì)
  ///   - Nếu synonymWord.trim() rỗng → return
  ///   - Nếu intensity không phải số → int.tryParse() trả về null (API xử lý)
  ///
  /// Ví dụ gọi:
  ///   Từ gốc: "thương", Từ đồng nghĩa: "yêu", Mức độ: 8, Ghi chú: "yêu nhiều hơn"
  ///   → api.addSynonym(wordId: 1, synonymWord: "yêu", intensity: 8, note: "yêu nhiều hơn")
  Future<void> _addSynonym() async {
    if (selectedWord == null) return;
    final synWord = synonymController.text.trim();
    if (synWord.isEmpty) return;
    await api.addSynonym(
      wordId: selectedWord!.id,
      synonymWord: synWord,
      intensity: int.tryParse(intensityController.text.trim()),
      frequency: frequencyController.text.trim(),
      note: noteController.text.trim(),
    );
    synonymController.clear();
    intensityController.clear();
    frequencyController.clear();
    noteController.clear();
    await _refresh();
  }

  /// _editSynonym: Sửa mối quan hệ đồng nghĩa hiện tại
  ///
  /// Tác dụng:
  ///   1. Mở một AlertDialog dialog có form để sửa các field
  ///   2. Copy giá trị hiện tại vào controller
  ///   3. User chỉnh sửa và nhấn "Lưu"
  ///   4. Gọi API PUT /admin/synonyms/{id}
  ///   5. Refresh danh sách
  ///
  /// Tham số:
  ///   - syn: Synonym object hiện tại (chứa id và các field cần sửa)
  ///
  /// Các field có thể sửa (trong dialog):
  ///   - synonymWord: Tên từ đồng nghĩa
  ///   - intensity: Mức độ (1-10)
  ///   - frequency: Tần suất
  ///   - note: Ghi chú
  ///
  /// Dialog logic:
  ///   - Hiển thị 4 TextField tương ứng 4 field
  ///   - Nút "Hủy" (pop false) → không lưu
  ///   - Nút "Lưu" (pop true) → gọi API update
  ///   - Nếu ok == true → gọi api.updateSynonym() rồi _refresh()
  ///
  /// Ví dụ:
  ///   syn = Synonym(id: 5, word: "thương", synonymWord: "yêu", intensity: 8)
  ///   User sửa intensity từ 8 → 9
  ///   → api.updateSynonym(5, intensity: 9)
  Future<void> _editSynonym(Synonym syn) async {
    final synWordCtrl = TextEditingController(text: syn.synonymWord ?? '');
    final intensityCtrl =
        TextEditingController(text: syn.intensity?.toString() ?? '');
    final freqCtrl = TextEditingController(text: syn.frequency ?? '');
    final noteCtrl = TextEditingController(text: syn.note ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sửa đồng nghĩa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: synWordCtrl,
                decoration: const InputDecoration(labelText: 'Từ đồng nghĩa')),
            TextField(
                controller: intensityCtrl,
                decoration: const InputDecoration(labelText: 'Mức độ'),
                keyboardType: TextInputType.number),
            TextField(
                controller: freqCtrl,
                decoration: const InputDecoration(labelText: 'Tần suất')),
            TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'Ghi chú')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Lưu')),
        ],
      ),
    );

    if (ok == true) {
      await api.updateSynonym(
        syn.id,
        synonymWord: synWordCtrl.text.trim(),
        intensity: int.tryParse(intensityCtrl.text.trim()),
        frequency: freqCtrl.text.trim(),
        note: noteCtrl.text.trim(),
      );
      await _refresh();
    }
  }

  /// _deleteSynonym: Xóa mối quan hệ đồng nghĩa
  ///
  /// Tác dụng:
  ///   1. Gọi API DELETE /admin/synonyms/{id}
  ///   2. Refresh danh sách (để UI không còn hiển thị item đã xóa)
  ///
  /// Tham số:
  ///   - id: ID của Synonym record cần xóa
  ///
  /// Thời điểm gọi:
  ///   - Khi user nhấn nút delete (X icon) trong list
  ///   - Không hỏi xác nhận (có thể thêm xác nhận dialog nếu cần)
  ///
  /// Ví dụ:
  ///   Xóa synonym với id=5
  ///   → api.deleteSynonym(5)
  ///   → /admin/synonyms/5 DELETE
  ///   → synonym bị xóa khỏi database
  ///   → _refresh() cập nhật UI
  Future<void> _deleteSynonym(int id) async {
    await api.deleteSynonym(id);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quản lý đồng nghĩa',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FutureBuilder<List<WordSummary>>(
                  future: wordsFuture,
                  builder: (context, snapshot) {
                    final items = snapshot.data ?? [];
                    return DropdownButtonFormField<WordSummary>(
                      value: selectedWord,
                      decoration:
                          const InputDecoration(labelText: 'Chọn từ gốc'),
                      items: items
                          .map((w) =>
                              DropdownMenuItem(value: w, child: Text(w.word)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => selectedWord = value),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Làm mới')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: TextField(
                      controller: synonymController,
                      decoration:
                          const InputDecoration(labelText: 'Từ đồng nghĩa'))),
              const SizedBox(width: 8),
              SizedBox(
                  width: 120,
                  child: TextField(
                      controller: intensityController,
                      decoration: const InputDecoration(labelText: 'Mức độ'),
                      keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              SizedBox(
                  width: 140,
                  child: TextField(
                      controller: frequencyController,
                      decoration:
                          const InputDecoration(labelText: 'Tần suất'))),
              const SizedBox(width: 8),
              SizedBox(
                  width: 180,
                  child: TextField(
                      controller: noteController,
                      decoration: const InputDecoration(labelText: 'Ghi chú'))),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                  onPressed: _addSynonym,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm')),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Synonym>>(
              future: synonymsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Không tải được danh sách đồng nghĩa.'));
                }
                final syns = snapshot.data ?? [];
                return ListView.separated(
                  itemCount: syns.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final syn = syns[index];
                    return ListTile(
                      title:
                          Text('${syn.word ?? ''} → ${syn.synonymWord ?? ''}'),
                      subtitle: Text([
                        if (syn.intensity != null) 'Mức: ${syn.intensity}',
                        if (syn.frequency != null && syn.frequency!.isNotEmpty)
                          'Tần suất: ${syn.frequency}',
                        if (syn.note != null && syn.note!.isNotEmpty) syn.note,
                      ].join(' • ')),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editSynonym(syn)),
                          IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteSynonym(syn.id)),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
