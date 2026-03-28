import 'package:flutter/material.dart';

import '../models/proverb.dart';
import '../models/word_summary.dart';
import '../services/api_client.dart';

class ProverbManagementScreen extends StatefulWidget {
  const ProverbManagementScreen({super.key});

  @override
  State<ProverbManagementScreen> createState() => _ProverbManagementScreenState();
}

class _ProverbManagementScreenState extends State<ProverbManagementScreen> {
  final ApiClient api = ApiClient();
  late Future<List<Proverb>> proverbsFuture;
  late Future<List<WordSummary>> wordsFuture;

  WordSummary? selectedWord;
  final TextEditingController phraseController = TextEditingController();
  final TextEditingController meaningController = TextEditingController();
  final TextEditingController usageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    proverbsFuture = api.listProverbs();
    wordsFuture = api.listWords();
  }

  Future<void> _refresh() async {
    setState(() {
      proverbsFuture = api.listProverbs();
    });
  }

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
            TextField(controller: phraseCtrl, decoration: const InputDecoration(labelText: 'Câu tục ngữ')),
            TextField(controller: meaningCtrl, decoration: const InputDecoration(labelText: 'Ý nghĩa')),
            TextField(controller: usageCtrl, decoration: const InputDecoration(labelText: 'Cách dùng')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Lưu')),
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
          const Text('Quản lý tục ngữ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                      decoration: const InputDecoration(labelText: 'Chọn từ gốc'),
                      items: items
                          .map((w) => DropdownMenuItem(value: w, child: Text(w.word)))
                          .toList(),
                      onChanged: (value) => setState(() => selectedWord = value),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(onPressed: _refresh, icon: const Icon(Icons.refresh), label: const Text('Làm mới')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: phraseController, decoration: const InputDecoration(labelText: 'Câu tục ngữ'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: meaningController, decoration: const InputDecoration(labelText: 'Ý nghĩa'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: usageController, decoration: const InputDecoration(labelText: 'Cách dùng'))),
              const SizedBox(width: 8),
              ElevatedButton.icon(onPressed: _addProverb, icon: const Icon(Icons.add), label: const Text('Thêm')),
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
                  return const Center(child: Text('Không tải được danh sách tục ngữ.'));
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
                          IconButton(icon: const Icon(Icons.edit), onPressed: () => _editProverb(p)),
                          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _deleteProverb(p.id)),
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
