import 'package:flutter/material.dart';

import '../models/word_detail.dart';
import '../models/word_summary.dart';
import '../services/api_client.dart';

class DictionaryManagementScreen extends StatefulWidget {
  const DictionaryManagementScreen({super.key});

  @override
  State<DictionaryManagementScreen> createState() => _DictionaryManagementScreenState();
}

class _DictionaryManagementScreenState extends State<DictionaryManagementScreen> {
  final ApiClient api = ApiClient();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController wordController = TextEditingController();
  final TextEditingController posController = TextEditingController();
  final TextEditingController meaningController = TextEditingController();
  final TextEditingController exampleController = TextEditingController();

  final TextEditingController editWordController = TextEditingController();
  final TextEditingController editPosController = TextEditingController();
  final TextEditingController editPronController = TextEditingController();
  final TextEditingController editFreqController = TextEditingController();
  final TextEditingController editRegisterController = TextEditingController();
  final TextEditingController editEtymologyController = TextEditingController();

  final TextEditingController newMeaningController = TextEditingController();
  final TextEditingController newExampleController = TextEditingController();

  late Future<List<WordSummary>> wordsFuture;
  WordSummary? selectedWord;
  WordDetail? selectedDetail;
  bool loadingDetail = false;

  @override
  void initState() {
    super.initState();
    wordsFuture = api.listWords();
  }

  Future<void> _refresh() async {
    setState(() {
      wordsFuture = api.listWords(query: searchController.text.trim());
    });
    if (selectedWord != null) {
      await _loadDetail(selectedWord!);
    }
  }

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

  Future<void> _createWord() async {
    final word = wordController.text.trim();
    final pos = posController.text.trim();
    final meaning = meaningController.text.trim();
    if (word.isEmpty || pos.isEmpty || meaning.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ từ, loại từ, nghĩa.')),
      );
      return;
    }
    await api.createWord(
      word: word,
      partOfSpeech: pos,
      meanings: [meaning],
      examples: exampleController.text.trim().isEmpty ? [] : [exampleController.text.trim()],
    );
    wordController.clear();
    posController.clear();
    meaningController.clear();
    exampleController.clear();
    await _refresh();
  }

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

  Future<void> _addMeaning() async {
    if (selectedWord == null) return;
    final def = newMeaningController.text.trim();
    if (def.isEmpty) return;
    await api.addMeaning(selectedWord!.id, def);
    newMeaningController.clear();
    await _loadDetail(selectedWord!);
  }

  Future<void> _editMeaning(int id, String current) async {
    final controller = TextEditingController(text: current);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sửa nghĩa'),
        content: TextField(controller: controller, maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Lưu')),
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Lưu')),
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
          const Text('Quản lý từ vựng', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                        return const Center(child: Text('Không tải được danh sách từ.'));
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
                            TextField(controller: wordController, decoration: const InputDecoration(labelText: 'Từ')),
                            const SizedBox(height: 8),
                            TextField(controller: posController, decoration: const InputDecoration(labelText: 'Loại từ')),
                            const SizedBox(height: 8),
                            TextField(controller: meaningController, decoration: const InputDecoration(labelText: 'Nghĩa'), maxLines: 3),
                            const SizedBox(height: 8),
                            TextField(controller: exampleController, decoration: const InputDecoration(labelText: 'Ví dụ (tuỳ chọn)'), maxLines: 2),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(onPressed: _createWord, icon: const Icon(Icons.add), label: const Text('Lưu từ')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _card(
                        title: 'Chỉnh sửa thông tin từ',
                        child: loadingDetail
                            ? const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
                            : selectedDetail == null
                                ? const Text('Chọn một từ để chỉnh sửa.')
                                : Column(
                                    children: [
                                      TextField(controller: editWordController, decoration: const InputDecoration(labelText: 'Từ')),
                                      const SizedBox(height: 8),
                                      TextField(controller: editPosController, decoration: const InputDecoration(labelText: 'Loại từ')),
                                      const SizedBox(height: 8),
                                      TextField(controller: editPronController, decoration: const InputDecoration(labelText: 'Phát âm')),
                                      const SizedBox(height: 8),
                                      TextField(controller: editFreqController, decoration: const InputDecoration(labelText: 'Tần suất')),
                                      const SizedBox(height: 8),
                                      TextField(controller: editRegisterController, decoration: const InputDecoration(labelText: 'Văn phong')),
                                      const SizedBox(height: 8),
                                      TextField(controller: editEtymologyController, decoration: const InputDecoration(labelText: 'Từ nguyên'), maxLines: 3),
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(onPressed: _updateWordInfo, icon: const Icon(Icons.save), label: const Text('Lưu thay đổi')),
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
                                  TextField(controller: newMeaningController, decoration: const InputDecoration(labelText: 'Nghĩa mới'), maxLines: 3),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(onPressed: _addMeaning, icon: const Icon(Icons.add), label: const Text('Thêm nghĩa')),
                                  const SizedBox(height: 12),
                                  ...selectedDetail!.meanings.map(
                                    (m) => ListTile(
                                      title: Text(m.definition),
                                      subtitle: Text('Thứ tự: ${m.senseOrder}'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(icon: const Icon(Icons.edit), onPressed: () => _editMeaning(m.id, m.definition)),
                                          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _deleteMeaning(m.id)),
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
                                  TextField(controller: newExampleController, decoration: const InputDecoration(labelText: 'Ví dụ mới'), maxLines: 2),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(onPressed: _addExample, icon: const Icon(Icons.add), label: const Text('Thêm ví dụ')),
                                  const SizedBox(height: 12),
                                  ...selectedDetail!.examples.map(
                                    (e) => ListTile(
                                      title: Text(e.exampleText),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(icon: const Icon(Icons.edit), onPressed: () => _editExample(e.id, e.exampleText)),
                                          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _deleteExample(e.id)),
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
