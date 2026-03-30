// ============================================================================
// FILE: proverb_management_screen.dart - TRANG QUẢN LÝ THÀNH NGỮ/TỤC NGỮ
// TÁC DỤG: Quản lý các thành ngữ liên quan đến các từ
// CHỨC NĂNG:
//   ➕ Thêm thành ngữ mới
//   📝 Nhập: cụm từ, ý nghĩa, cách sử dụng
//   ✏️ Sửa chi tiết
//   ✗ Xóa thành ngữ
// ============================================================================

import 'package:flutter/material.dart';

import '../models/proverb.dart';
import '../models/word_summary.dart';
import '../services/api_client.dart';

class ProverbManagementScreen extends StatefulWidget {
  const ProverbManagementScreen({super.key});

  @override
  State<ProverbManagementScreen> createState() =>
      _ProverbManagementScreenState();
}

class _ProverbManagementScreenState extends State<ProverbManagementScreen> {
  /// ============================================================================
  /// BIẾN TRẠNG THÁI (State Variables)
  /// ============================================================================

  /// API client để gọi các endpoint backend
  /// - Type: ApiClient
  /// - Dùng để: listProverbs(), addProverb(), updateProverb(), deleteProverb()
  /// - Khởi tạo: một instance duy nhất
  final ApiClient api = ApiClient();

  /// Future để tải danh sách tất cả các thành ngữ/tục ngữ từ backend
  /// - Gọi từ: api.listProverbs() → GET /admin/proverbs
  /// - Giá trị trả về: List<Proverb> (tất cả tục ngữ trong database)
  /// - Dùng trong: FutureBuilder để hiển thị danh sách
  /// - Được cập nhật: khi user nhấn Refresh hay sau CRUD operation
  late Future<List<Proverb>> proverbsFuture;

  /// Future để tải danh sách tất cả các từ (dùng cho dropdown chọn từ gốc)
  /// - Gọi từ: api.listWords() → GET /words
  /// - Giá trị trả về: List<WordSummary> (tất cả từ trong database)
  /// - Dùng trong: DropdownButtonFormField để user chọn từ
  /// - Được cập nhật: khi initState
  late Future<List<WordSummary>> wordsFuture;

  /// Từ hiện đang được chọn (từ gốc - từ có liên quan đến tục ngữ)
  /// - Type: WordSummary? (nullable)
  /// - Dùng để: biết tục ngữ nào liên quan đến từ nào
  /// - Giá trị: null khi chưa chọn, WordSummary khi đã chọn từ trong dropdown
  /// - Kiểm tra: _addProverb() sẽ return nếu selectedWord == null
  /// - Ví dụ: chọn từ "thương" để thêm tục ngữ "thương người như thương thân"
  WordSummary? selectedWord;

  /// TextEditingController cho input "Câu tục ngữ" (phrase)
  /// - Type: TextEditingController
  /// - Giá trị nhập vào: Câu tục ngữ/thành ngữ gốc
  /// - Ví dụ: "thương người như thương thân"
  /// - Điểm khác: tục ngữ **không** được dịch từng chữ, phải dịch toàn bộ
  /// - Sử dụng: lấy giá trị trong _addProverb() rồi trim()
  /// - Làm sạch: sau khi submit, gọi .clear()
  final TextEditingController phraseController = TextEditingController();

  /// TextEditingController cho input "Ý nghĩa" (meaning)
  /// - Type: TextEditingController
  /// - Giá trị nhập vào: Ý nghĩa/dịch nghĩa của cả câu tục ngữ
  /// - Ví dụ: "yêu thương người khác như yêu thương chính mình"
  /// - Điểm quan trọng: dịch **toàn bộ ý** không phải dịch word-by-word
  /// - Sử dụng: giữ nguyên string
  /// - Làm sạch: sau khi submit, gọi .clear()
  final TextEditingController meaningController = TextEditingController();

  /// TextEditingController cho input "Cách dùng" (usage)
  /// - Type: TextEditingController
  /// - Giá trị nhập vào: Bối cảnh/tình huống sử dụng tục ngữ
  /// - Ví dụ: "dùng để nhấn mạnh sự yêu thương vô điều kiện"
  /// - Giúp người dùng hiểu khi nào dùng tục ngữ này
  /// - Sử dụng: giữ nguyên string
  /// - Làm sạch: sau khi submit, gọi .clear()
  final TextEditingController usageController = TextEditingController();

  /// ============================================================================
  /// LIFECYCLE METHODS
  /// ============================================================================

  /// initState: Khởi tạo state khi screen lần đầu tải
  ///
  /// Tác dụng:
  ///   1. Gọi super.initState()
  ///   2. Load danh sách tục ngữ từ backend
  ///   3. Load danh sách từ cho dropdown
  ///
  /// Process:
  ///   - proverbsFuture = api.listProverbs() → GET /admin/proverbs
  ///   - wordsFuture = api.listWords() → GET /words
  ///   - Cả hai gọi async nhưng không await (để UI không bị block)
  ///   - FutureBuilder trong build() sẽ xử lý khi data về
  @override
  void initState() {
    super.initState();
    proverbsFuture = api.listProverbs();
    wordsFuture = api.listWords();
  }

  /// ============================================================================
  /// CRUD METHODS
  /// ============================================================================

  /// _refresh: Làm mới danh sách tục ngữ
  ///
  /// Tác dụng:
  ///   - Gọi lại api.listProverbs() để lấy dữ liệu mới nhất từ backend
  ///   - Gọi setState() để trigger rebuild UI
  ///   - Làm cho FutureBuilder lấy Future mới
  ///
  /// Thời điểm gọi:
  ///   - Sau khi thêm tục ngữ (_addProverb)
  ///   - Sau khi sửa tục ngữ (_editProverb)
  ///   - Sau khi xóa tục ngữ (_deleteProverb)
  ///   - Khi user nhấn nút "Làm mới"
  ///
  /// Ví dụ workflow:
  ///   user nhấp "Thêm" → _addProverb() call API → _refresh() → UI update
  Future<void> _refresh() async {
    setState(() {
      proverbsFuture = api.listProverbs();
    });
  }

  /// _addProverb: Thêm tục ngữ/thành ngữ mới
  ///
  /// Tác dụng:
  ///   1. Kiểm tra xem user đã chọn từ gốc (selectedWord) chưa
  ///   2. Lấy câu tục ngữ từ phraseController
  ///   3. Gọi API POST /admin/proverbs để thêm và xác định từ liên quan
  ///   4. Clear tất cả input field
  ///   5. Refresh danh sách
  ///
  /// Tham số gửi tới API:
  ///   - wordId: ID của từ có liên quan (ví dụ: ID của "thương")
  ///   - phrase: Câu tục ngữ gốc (ví dụ: "thương người như thương thân")
  ///   - meaning: Ý nghĩa/dịch toàn bộ (ví dụ: "yêu thương tha nhân như chính mình")
  ///   - usage: Bối cảnh sử dụng (optional)
  ///
  /// Kiểm tra validation:
  ///   - Nếu selectedWord == null → return (không làm gì)
  ///   - Nếu phrase.trim() rỗng → return
  ///   - meaning và usage optional
  ///
  /// Ví dụ gọi:
  ///   Từ gốc: "thương" (id=1)
  ///   Phrase: "thương người như thương thân"
  ///   Meaning: "yêu thương người khác như yêu thương chính mình"
  ///   Usage: "dùng để nói về tình yêu vô điều kiện"
  ///   → api.addProverb(wordId: 1, phrase: "...", meaning: "...", usage: "...")
  Future<void> _addProverb() async {
    if (selectedWord == null) return;
    final phrase = phraseController.text.trim();
    if (phrase.isEmpty) return;
    await api.addProverb(
      wordId: selectedWord!.id,
      phrase: phrase,
      meaning: meaningController.text.trim(),
      usage: usageController.text.trim(),
    );
    phraseController.clear();
    meaningController.clear();
    usageController.clear();
    await _refresh();
  }

  /// _editProverb: Sửa tục ngữ/thành ngữ hiện tại
  ///
  /// Tác dụng:
  ///   1. Mở một AlertDialog có form để sửa các field
  ///   2. Copy giá trị hiện tại từ Proverb object vào controller
  ///   3. User chỉnh sửa và nhấn "Lưu"
  ///   4. Gọi API PUT /admin/proverbs/{id}
  ///   5. Refresh danh sách
  ///
  /// Tham số:
  ///   - p: Proverb object hiện tại (chứa id, phrase, meaning, usage)
  ///
  /// Các field có thể sửa (trong dialog):
  ///   - phrase: Câu tục ngữ
  ///   - meaning: Ý nghĩa
  ///   - usage: Cách dùng
  ///
  /// Dialog logic:
  ///   - Hiển thị 3 TextField cho 3 field
  ///   - Nút "Hủy" (pop false) → không lưu
  ///   - Nút "Lưu" (pop true) → gọi API update
  ///   - Nếu ok == true → gọi api.updateProverb() rồi _refresh()
  ///
  /// Ví dụ:
  ///   p = Proverb(id: 10, phrase: "thương người như thương thân", ...)
  ///   User sửa meaning từ cũ → mới
  ///   → api.updateProverb(10, phrase: "...", meaning: "...", usage: "...")
  Future<void> _editProverb(Proverb p) async {
    final phraseCtrl = TextEditingController(text: p.phrase);
    final meaningCtrl = TextEditingController(text: p.meaning ?? '');
    final usageCtrl = TextEditingController(text: p.usage ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sửa tục ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: phraseCtrl,
                decoration: const InputDecoration(labelText: 'Câu tục ngữ')),
            TextField(
                controller: meaningCtrl,
                decoration: const InputDecoration(labelText: 'Ý nghĩa')),
            TextField(
                controller: usageCtrl,
                decoration: const InputDecoration(labelText: 'Cách dùng')),
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
      await api.updateProverb(
        p.id,
        phrase: phraseCtrl.text.trim(),
        meaning: meaningCtrl.text.trim(),
        usage: usageCtrl.text.trim(),
      );
      await _refresh();
    }
  }

  /// _deleteProverb: Xóa tục ngữ/thành ngữ
  ///
  /// Tác dụng:
  ///   1. Gọi API DELETE /admin/proverbs/{id}
  ///   2. Refresh danh sách (để UI không còn hiển thị item đã xóa)
  ///
  /// Tham số:
  ///   - id: ID của Proverb record cần xóa
  ///
  /// Thời điểm gọi:
  ///   - Khi user nhấn nút delete (X icon) trong list
  ///   - Không hỏi xác nhận (có thể thêm xác nhận dialog nếu cần)
  ///
  /// Ví dụ:
  ///   Xóa proverb với id=10
  ///   → api.deleteProverb(10)
  ///   → /admin/proverbs/10 DELETE
  ///   → tục ngữ bị xóa khỏi database
  ///   → _refresh() cập nhật UI
  Future<void> _deleteProverb(int id) async {
    await api.deleteProverb(id);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quản lý tục ngữ',
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
                      controller: phraseController,
                      decoration:
                          const InputDecoration(labelText: 'Câu tục ngữ'))),
              const SizedBox(width: 8),
              Expanded(
                  child: TextField(
                      controller: meaningController,
                      decoration: const InputDecoration(labelText: 'Ý nghĩa'))),
              const SizedBox(width: 8),
              Expanded(
                  child: TextField(
                      controller: usageController,
                      decoration:
                          const InputDecoration(labelText: 'Cách dùng'))),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                  onPressed: _addProverb,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm')),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Proverb>>(
              future: proverbsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Không tải được danh sách tục ngữ.'));
                }
                final items = snapshot.data ?? [];
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = items[index];
                    return ListTile(
                      title: Text('${p.word ?? ''} - ${p.phrase}'),
                      subtitle: Text(p.meaning ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editProverb(p)),
                          IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteProverb(p.id)),
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
