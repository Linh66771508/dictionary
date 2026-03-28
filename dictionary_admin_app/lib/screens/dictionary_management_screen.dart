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

  final TextEditingController synonymController = TextEditingController();
  final TextEditingController synonymIntensityController = TextEditingController();
  final TextEditingController synonymFrequencyController = TextEditingController();
  final TextEditingController synonymNoteController = TextEditingController();

  final TextEditingController proverbPhraseController = TextEditingController();
  final TextEditingController proverbMeaningController = TextEditingController();
  final TextEditingController proverbUsageController = TextEditingController();

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

  Future<void> _addSynonym() async {
    if (selectedWord == null) return;
    final word = synonymController.text.trim();
    if (word.isEmpty) return;
    final intensity = int.tryParse(synonymIntensityController.text.trim());
    await api.addSynonym(
      wordId: selectedWord!.id,
      synonymWord: word,
      intensity: intensity,
      frequency: synonymFrequencyController.text.trim(),
      note: synonymNoteController.text.trim(),
    );
    synonymController.clear();
    synonymIntensityController.clear();
    synonymFrequencyController.clear();
    synonymNoteController.clear();
    await _loadDetail(selectedWord!);
  }

  Future<void> _deleteSynonym(int id) async {
    await api.deleteSynonym(id);
    if (selectedWord != null) {
      await _loadDetail(selectedWord!);
    }
  }

  Future<void> _addProverb() async {
    if (selectedWord == null) return;
    final phrase = proverbPhraseController.text.trim();
    if (phrase.isEmpty) return;
    await api.addProverb(
      wordId: selectedWord!.id,
      phrase: phrase,
      meaning: proverbMeaningController.text.trim(),
      usage: proverbUsageController.text.trim(),
    );
    proverbPhraseController.clear();
    proverbMeaningController.clear();
    proverbUsageController.clear();
    await _loadDetail(selectedWord!);
  }

  Future<void> _deleteProverb(int id) async {
    await api.deleteProverb(id);
    if (selectedWord != null) {
      await _loadDetail(selectedWord!);
    }
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
                        title: 'Đồng nghĩa & Tục ngữ',
                        child: loadingDetail
                            ? const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
                            : selectedDetail == null
                                ? const Text('Chọn một từ để quản lý đồng nghĩa và tục ngữ.')
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(selectedDetail!.word, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 12),
                                      const Text('Thêm đồng nghĩa', style: TextStyle(fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 8),
                                      TextField(controller: synonymController, decoration: const InputDecoration(labelText: 'Từ đồng nghĩa')),
                                      const SizedBox(height: 8),
                                      TextField(controller: synonymIntensityController, decoration: const InputDecoration(labelText: 'Mức độ (0-100)'), keyboardType: TextInputType.number),
                                      const SizedBox(height: 8),
                                      TextField(controller: synonymFrequencyController, decoration: const InputDecoration(labelText: 'Tần suất')),
                                      const SizedBox(height: 8),
                                      TextField(controller: synonymNoteController, decoration: const InputDecoration(labelText: 'Ghi chú')),
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(onPressed: _addSynonym, icon: const Icon(Icons.add), label: const Text('Thêm đồng nghĩa')),
                                      const SizedBox(height: 12),
                                      ...selectedDetail!.synonyms.map(
                                        (syn) => ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(syn.word),
                                          subtitle: Text([
                                            if (syn.intensity != null) 'Mức: ${syn.intensity}',
                                            if (syn.frequency != null && syn.frequency!.isNotEmpty) 'Tần suất: ${syn.frequency}',
                                            if (syn.note != null && syn.note!.isNotEmpty) syn.note,
                                          ].join(' • ')),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.delete_outline),
                                            onPressed: () => _deleteSynonym(syn.id),
                                          ),
                                        ),
                                      ),
                                      const Divider(height: 28),
                                      const Text('Thêm tục ngữ / thành ngữ', style: TextStyle(fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 8),
                                      TextField(controller: proverbPhraseController, decoration: const InputDecoration(labelText: 'Câu tục ngữ')),
                                      const SizedBox(height: 8),
                                      TextField(controller: proverbMeaningController, decoration: const InputDecoration(labelText: 'Ý nghĩa'), maxLines: 2),
                                      const SizedBox(height: 8),
                                      TextField(controller: proverbUsageController, decoration: const InputDecoration(labelText: 'Cách dùng'), maxLines: 2),
                                      const SizedBox(height: 8),
                                      ElevatedButton.icon(onPressed: _addProverb, icon: const Icon(Icons.add), label: const Text('Thêm tục ngữ')),
                                      const SizedBox(height: 12),
                                      ...selectedDetail!.proverbs.map(
                                        (p) => ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(p.phrase),
                                          subtitle: Text(p.meaning ?? ''),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.delete_outline),
                                            onPressed: () => _deleteProverb(p.id),
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
