// ============================================================================
// FILE: dictionary_management_screen.dart - TRANG QUẢN LÝ TỪ VỰNG
// TÁC DỤG: Quản lý các từ trong từ điển
// CHỨC NĂNG:
//   ➕ Thêm từ mới
//   ✏️ Sửa thông tin từ (tên, loại, phát âm)
//   ➕ Thêm nghĩa và ví dụ
//   ✗ Xóa từ
//   🔍 Tìm kiếm từ theo tên
// ============================================================================

import 'package:flutter/material.dart';

import '../models/word_detail.dart';
import '../models/word_summary.dart';
import '../services/api_client.dart';

class DictionaryManagementScreen extends StatefulWidget {
  const DictionaryManagementScreen({super.key});

  @override
  State<DictionaryManagementScreen> createState() =>
      _DictionaryManagementScreenState();
}

class _DictionaryManagementScreenState
    extends State<DictionaryManagementScreen> {
  /// Flutter API client instance
  final ApiClient api = ApiClient();

  /// ===== TEXT EDITING CONTROLLERS =====
  /// Controllers để quản lý input từ user (search, create, edit)

  /// Ô tìm kiếm từ vựng
  final TextEditingController searchController = TextEditingController();

  /// Ô tạo từ mới (create form)
  final TextEditingController wordController = TextEditingController();
  final TextEditingController posController = TextEditingController();
  final TextEditingController meaningController = TextEditingController();
  final TextEditingController exampleController = TextEditingController();

  /// Ô sửa thông tin từ (edit form)
  /// - name, part_of_speech, pronunciation, frequency, register, etymology
  /// - Dùng khi user select một từ để sửa thông tin cơ bản
  final TextEditingController editWordController = TextEditingController();
  final TextEditingController editPosController = TextEditingController();
  final TextEditingController editPronController = TextEditingController();
  final TextEditingController editFreqController = TextEditingController();
  final TextEditingController editRegisterController = TextEditingController();
  final TextEditingController editEtymologyController = TextEditingController();

  /// Ô thêm nghĩa/ví dụ mới cho từ hiện tại
  final TextEditingController newMeaningController = TextEditingController();
  final TextEditingController newExampleController = TextEditingController();

  /// ===== STATE VARIABLES =====

  /// Future chứa danh sách tất cả từ (hoặc từ tìm kiếm)
  /// - Dùng cho FutureBuilder để hiển thị list words
  /// - Được set lại khi search hoặc refresh
  late Future<List<WordSummary>> wordsFuture;

  /// Từ hiện tại đang select (just metadata: id, word, part_of_speech)
  /// - Dùng để track đâu là "selected row" trong list
  /// - Khi user click vào một từ -> selectedWord được set -> _loadDetail gọi
  WordSummary? selectedWord;

  /// Thông tin chi tiết của selectedWord (đầy đủ: meanings, examples, synonyms, ...)
  /// - Dùng để hiển thị details panel bên tay phải
  /// - Được load từ API khi user select một từ
  /// - Chứa tất cả nested info (meanings, examples, synonyms, proverbs, ...)
  WordDetail? selectedDetail;

  /// Flag theo dõi trạng thái loading detail
  /// - true khi đang fetch detail từ API
  /// - false khi fetch xong
  /// - Dùng để hiển thị loading spinner
  bool loadingDetail = false;

  /// Lifecycle: initState gọi lần đầu khi widget được tạo
  /// Tác dụng:
  ///   1. Gọi super.initState()
  ///   2. Initialize wordsFuture = api.listWords() để fetch danh sách từ
  ///   3. FutureBuilder sẽ theo dõi Future này
  @override
  void initState() {
    super.initState();
    wordsFuture = api.listWords();
  }

  /// Refresh danh sách từ và detail
  /// Process:
  ///   1. Query api.listWords() với search string hiện tại
  ///   2. setState() để rebuild word list
  ///   3. Nếu đang select một từ -> reload detail của từ đó
  ///   4. Dùng khi: user tạo/xóa/sửa từ -> cần refresh list
  Future<void> _refresh() async {
    setState(() {
      wordsFuture = api.listWords(query: searchController.text.trim());
    });
    if (selectedWord != null) {
      await _loadDetail(selectedWord!);
    }
  }

  /// Load thông tin chi tiết của một từ từ API
  /// Tham số:
  ///   word: WordSummary object (chứa id, word, part_of_speech)
  /// Process:
  ///   1. setState() set loadingDetail = true, mark selected word
  ///   2. Gọi api.getWordDetail(word.id) để fetch full info
  ///   3. Nếu widget unmounted -> return (tránh crash)
  ///   4. setState() populate edit controllers từ detail data
  ///   5. Set loadingDetail = false (hide loading spinner)
  /// Populates:
  ///   - editWordController, editPosController, editPronController,
  ///   - editFreqController, editRegisterController, editEtymologyController
  ///   - selectedDetail (dùng để display meanings, examples, synonyms)
  Future<void> _loadDetail(WordSummary word) async {
    setState(() {
      loadingDetail = true;
      selectedWord = word;
    });
    final detail = await api.getWordDetail(word.id);
    if (!mounted) return;
    setState(() {
      selectedDetail = detail;
      loadingDetail = false;
      editWordController.text = detail.word;
      editPosController.text = detail.partOfSpeech ?? '';
      editPronController.text = detail.pronunciation ?? '';
      editFreqController.text = detail.frequency ?? '';
      editRegisterController.text = detail.register ?? '';
      editEtymologyController.text = detail.etymology ?? '';
    });
  }

  /// Tạo từ mới
  /// Tham số: value từ các text controllers
  /// Validation:
  ///   - word, partOfSpeech, meaning không được rỗng
  ///   - Nếu không valid -> show SnackBar error
  /// Process:
  ///   1. Lấy giá trị từ controllers và trim()
  ///   2. Validate (không rỗng)
  ///   3. Gọi api.createWord() với payload
  ///   4. Clear các controllers
  ///   5. Gọi _refresh() để cập nhật danh sách
  Future<void> _createWord() async {
    final word = wordController.text.trim();
    final pos = posController.text.trim();
    final meaning = meaningController.text.trim();
    if (word.isEmpty || pos.isEmpty || meaning.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng nhập đầy đủ từ, loại từ, nghĩa.')),
      );
      return;
    }
    await api.createWord(
      word: word,
      partOfSpeech: pos,
      meanings: [meaning],
      examples: exampleController.text.trim().isEmpty
          ? []
          : [exampleController.text.trim()],
    );
    wordController.clear();
    posController.clear();
    meaningController.clear();
    exampleController.clear();
    await _refresh();
  }

  /// Xóa một từ
  /// Tham số: id của từ cần xóa
  /// Process:
  ///   1. Gọi api.deleteWord(id)
  ///   2. Nếu deleted word là selected word -> clear selectedWord, selectedDetail
  ///   3. Gọi _refresh() để cập nhật list
  Future<void> _deleteWord(int id) async {
    await api.deleteWord(id);
    if (selectedWord?.id == id) {
      setState(() {
        selectedWord = null;
        selectedDetail = null;
      });
    }
    await _refresh();
  }

  /// Cập nhật thông tin cơ bản của từ (word name, pos, pronunciation, ...)
  /// Validation: selectedWord không được null
  /// Payload: dictionary chứa các field cần update
  /// Process:
  ///   1. Lấy các giá trị từ edit controllers
  ///   2. Gọi api.updateWord(id, payload)
  ///   3. Reload detail để refresh UI
  Future<void> _updateWordInfo() async {
    if (selectedWord == null) return;
    await api.updateWord(selectedWord!.id, {
      'word': editWordController.text.trim(),
      'part_of_speech': editPosController.text.trim(),
      'pronunciation': editPronController.text.trim(),
      'frequency': editFreqController.text.trim(),
      'register': editRegisterController.text.trim(),
      'etymology': editEtymologyController.text.trim(),
    });
    await _loadDetail(selectedWord!);
  }

  /// Thêm một định nghĩa (meaning) mới cho từ hiện tại
  /// Validation:
  ///   - selectedWord không được null
  ///   - meaning text không được rỗng
  /// Process:
  ///   1. Lấy text từ newMeaningController
  ///   2. Gọi api.addMeaning(word_id, definition)
  ///   3. Clear controller
  ///   4. Reload detail để refresh meanings list
  Future<void> _addMeaning() async {
    if (selectedWord == null) return;
    final def = newMeaningController.text.trim();
    if (def.isEmpty) return;
    await api.addMeaning(selectedWord!.id, def);
    newMeaningController.clear();
    await _loadDetail(selectedWord!);
  }

  /// Sửa một định nghĩa (show dialog, user edit, save)
  /// Tham số:
  ///   id: meaning_id cần sửa
  ///   current: text hiện tại
  /// Process:
  ///   1. Show AlertDialog với TextField pre-filled current text
  ///   2. User sửa text, click Save hoặc Cancel
  ///   3. Nếu Save -> gọi api.updateMeaning(id, new_text)
  ///   4. Reload detail để refresh
  Future<void> _editMeaning(int id, String current) async {
    final controller = TextEditingController(text: current);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sửa nghĩa'),
        content: TextField(controller: controller, maxLines: 3),
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
      await api.updateMeaning(id, definition: controller.text.trim());
      await _loadDetail(selectedWord!);
    }
  }

  Future<void> _deleteMeaning(int id) async {
    await api.deleteMeaning(id);
    await _loadDetail(selectedWord!);
  }

  Future<void> _addExample() async {
    if (selectedWord == null) return;
    final text = newExampleController.text.trim();
    if (text.isEmpty) return;
    await api.addExample(selectedWord!.id, text);
    newExampleController.clear();
    await _loadDetail(selectedWord!);
  }

  Future<void> _editExample(int id, String current) async {
    final controller = TextEditingController(text: current);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sửa ví dụ'),
        content: TextField(controller: controller, maxLines: 3),
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
      await api.updateExample(id, controller.text.trim());
      await _loadDetail(selectedWord!);
    }
  }

  Future<void> _deleteExample(int id) async {
    await api.deleteExample(id);
    await _loadDetail(selectedWord!);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quản lý từ vựng',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Tìm từ...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _refresh(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Làm mới'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: FutureBuilder<List<WordSummary>>(
                    future: wordsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text('Không tải được danh sách từ.'));
                      }
                      final words = snapshot.data ?? [];
                      return ListView.separated(
                        itemCount: words.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final word = words[index];
                          final isSelected = selectedWord?.id == word.id;
                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: const Color(0xFFEFF6FF),
                            title: Text(word.word),
                            subtitle: Text(word.shortDef ?? ''),
                            onTap: () => _loadDetail(word),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteWord(word.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ListView(
                    children: [
                      _card(
                        title: 'Thêm từ mới',
                        child: Column(
                          children: [
                            TextField(
                                controller: wordController,
                                decoration:
                                    const InputDecoration(labelText: 'Từ')),
                            const SizedBox(height: 8),
                            TextField(
                                controller: posController,
                                decoration: const InputDecoration(
                                    labelText: 'Loại từ')),
                            const SizedBox(height: 8),
                            TextField(
                                controller: meaningController,
                                decoration:
                                    const InputDecoration(labelText: 'Nghĩa'),
                                maxLines: 3),
                            const SizedBox(height: 8),
                            TextField(
                                controller: exampleController,
                                decoration: const InputDecoration(
                                    labelText: 'Ví dụ (tuỳ chọn)'),
                                maxLines: 2),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                                onPressed: _createWord,
                                icon: const Icon(Icons.add),
                                label: const Text('Lưu từ')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _card(
                        title: 'Chỉnh sửa thông tin từ',
                        child: loadingDetail
                            ? const Center(
                                child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator()))
                            : selectedDetail == null
                                ? const Text('Chọn một từ để chỉnh sửa.')
                                : Column(
                                    children: [
                                      TextField(
                                          controller: editWordController,
                                          decoration: const InputDecoration(
                                              labelText: 'Từ')),
                                      const SizedBox(height: 8),
                                      TextField(
                                          controller: editPosController,
                                          decoration: const InputDecoration(
                                              labelText: 'Loại từ')),
                                      const SizedBox(height: 8),
                                      TextField(
                                          controller: editPronController,
                                          decoration: const InputDecoration(
                                              labelText: 'Phát âm')),
                                      const SizedBox(height: 8),
                                      TextField(
                                          controller: editFreqController,
                                          decoration: const InputDecoration(
                                              labelText: 'Tần suất')),
                                      const SizedBox(height: 8),
                                      TextField(
                                          controller: editRegisterController,
                                          decoration: const InputDecoration(
                                              labelText: 'Văn phong')),
                                      const SizedBox(height: 8),
                                      TextField(
                                          controller: editEtymologyController,
                                          decoration: const InputDecoration(
                                              labelText: 'Từ nguyên'),
                                          maxLines: 3),
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(
                                          onPressed: _updateWordInfo,
                                          icon: const Icon(Icons.save),
                                          label: const Text('Lưu thay đổi')),
                                    ],
                                  ),
                      ),
                      const SizedBox(height: 16),
                      _card(
                        title: 'Quản lý nghĩa',
                        child: selectedDetail == null
                            ? const Text('Chọn một từ để quản lý nghĩa.')
                            : Column(
                                children: [
                                  TextField(
                                      controller: newMeaningController,
                                      decoration: const InputDecoration(
                                          labelText: 'Nghĩa mới'),
                                      maxLines: 3),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                      onPressed: _addMeaning,
                                      icon: const Icon(Icons.add),
                                      label: const Text('Thêm nghĩa')),
                                  const SizedBox(height: 12),
                                  ...selectedDetail!.meanings.map(
                                    (m) => ListTile(
                                      title: Text(m.definition),
                                      subtitle: Text('Thứ tự: ${m.senseOrder}'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () => _editMeaning(
                                                  m.id, m.definition)),
                                          IconButton(
                                              icon: const Icon(
                                                  Icons.delete_outline),
                                              onPressed: () =>
                                                  _deleteMeaning(m.id)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 16),
                      _card(
                        title: 'Quản lý ví dụ',
                        child: selectedDetail == null
                            ? const Text('Chọn một từ để quản lý ví dụ.')
                            : Column(
                                children: [
                                  TextField(
                                      controller: newExampleController,
                                      decoration: const InputDecoration(
                                          labelText: 'Ví dụ mới'),
                                      maxLines: 2),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                      onPressed: _addExample,
                                      icon: const Icon(Icons.add),
                                      label: const Text('Thêm ví dụ')),
                                  const SizedBox(height: 12),
                                  ...selectedDetail!.examples.map(
                                    (e) => ListTile(
                                      title: Text(e.exampleText),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () => _editExample(
                                                  e.id, e.exampleText)),
                                          IconButton(
                                              icon: const Icon(
                                                  Icons.delete_outline),
                                              onPressed: () =>
                                                  _deleteExample(e.id)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
