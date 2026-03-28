import 'package:flutter/material.dart';

import '../models/synonym.dart';
import '../models/word_summary.dart';
import '../services/api_client.dart';

class SynonymManagementScreen extends StatefulWidget {
  const SynonymManagementScreen({super.key});

  @override
  State<SynonymManagementScreen> createState() => _SynonymManagementScreenState();
}

class _SynonymManagementScreenState extends State<SynonymManagementScreen> {
  final ApiClient api = ApiClient();
  late Future<List<Synonym>> synonymsFuture;
  late Future<List<WordSummary>> wordsFuture;

  WordSummary? selectedWord;
  final TextEditingController synonymController = TextEditingController();
  final TextEditingController intensityController = TextEditingController();
  final TextEditingController frequencyController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    synonymsFuture = api.listSynonyms();
    wordsFuture = api.listWords();
  }

  Future<void> _refresh() async {
    setState(() {
      synonymsFuture = api.listSynonyms();
    });
  }

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

  Future<void> _editSynonym(Synonym syn) async {
    final synWordCtrl = TextEditingController(text: syn.synonymWord ?? '');
    final intensityCtrl = TextEditingController(text: syn.intensity?.toString() ?? '');
    final freqCtrl = TextEditingController(text: syn.frequency ?? '');
    final noteCtrl = TextEditingController(text: syn.note ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sửa đồng nghĩa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: synWordCtrl, decoration: const InputDecoration(labelText: 'Từ đồng nghĩa')),
            TextField(controller: intensityCtrl, decoration: const InputDecoration(labelText: 'Mức độ'), keyboardType: TextInputType.number),
            TextField(controller: freqCtrl, decoration: const InputDecoration(labelText: 'Tần suất')),
            TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Ghi chú')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Lưu')),
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
          const Text('Quản lý đồng nghĩa', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
              Expanded(child: TextField(controller: synonymController, decoration: const InputDecoration(labelText: 'Từ đồng nghĩa'))),
              const SizedBox(width: 8),
              SizedBox(width: 120, child: TextField(controller: intensityController, decoration: const InputDecoration(labelText: 'Mức độ'), keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              SizedBox(width: 140, child: TextField(controller: frequencyController, decoration: const InputDecoration(labelText: 'Tần suất'))),
              const SizedBox(width: 8),
              SizedBox(width: 180, child: TextField(controller: noteController, decoration: const InputDecoration(labelText: 'Ghi chú'))),
              const SizedBox(width: 8),
              ElevatedButton.icon(onPressed: _addSynonym, icon: const Icon(Icons.add), label: const Text('Thêm')),
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
                  return const Center(child: Text('Không tải được danh sách đồng nghĩa.'));
                }
                final syns = snapshot.data ?? [];
                return ListView.separated(
                  itemCount: syns.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final syn = syns[index];
                    return ListTile(
                      title: Text('${syn.word ?? ''} → ${syn.synonymWord ?? ''}'),
                      subtitle: Text([
                        if (syn.intensity != null) 'Mức: ${syn.intensity}',
                        if (syn.frequency != null && syn.frequency!.isNotEmpty) 'Tần suất: ${syn.frequency}',
                        if (syn.note != null && syn.note!.isNotEmpty) syn.note,
                      ].join(' • ')),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit), onPressed: () => _editSynonym(syn)),
                          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _deleteSynonym(syn.id)),
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
