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
  final ApiClient api = ApiClient();
  final TextEditingController searchController = TextEditingController();
  List<Topic> topics = [];
  Topic? selected;
  List<WordSummary> topicWords = [];
  List<WordSummary> searchResults = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

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

  Future<void> _loadTopicWords() async {
    if (selected == null) {
      setState(() => topicWords = []);
      return;
    }
    final data = await api.listTopicWords(selected!.id);
    if (!mounted) return;
    setState(() => topicWords = data);
  }

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
                  decoration: const InputDecoration(labelText: 'Icon (tùy chọn)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
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
        description: descController.text.trim().isEmpty ? null : descController.text.trim(),
        icon: iconController.text.trim().isEmpty ? null : iconController.text.trim(),
      );
      await _loadTopics();
    }
  }

  Future<void> _deleteTopic(Topic topic) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa chủ đề'),
          content: Text('Bạn có chắc muốn xóa chủ đề "${topic.name}"?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
          ],
        );
      },
    );
    if (result == true) {
      await api.deleteTopic(topic.id);
      await _loadTopics();
    }
  }

  Future<void> _searchWords() async {
    final query = searchController.text.trim();
    if (query.isEmpty) return;
    final data = await api.listWords(query: query);
    if (!mounted) return;
    setState(() => searchResults = data);
  }

  void _clearSearchResults() {
    setState(() => searchResults = []);
  }

  Future<void> _addWordToTopic(WordSummary word) async {
    if (selected == null) return;
    await api.addWordToTopic(selected!.id, word.id);
    await _loadTopicWords();
  }

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
                    child: Text('Danh sách chủ đề', style: TextStyle(fontWeight: FontWeight.bold)),
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
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                                      subtitle: word.shortDef == null ? null : Text(word.shortDef!),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
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
                                      subtitle: word.shortDef == null ? null : Text(word.shortDef!),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.remove_circle_outline),
                                        onPressed: () => _removeWordFromTopic(word),
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
