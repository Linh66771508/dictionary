import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool isBusy;

  const SearchBar({
    super.key,
    required this.controller,
    required this.onSubmit,
    this.onChanged,
    this.onClear,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 3)),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Color(0xFF2563EB)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Nhập từ cần tra...',
                    border: InputBorder.none,
                  ),
                  onChanged: onChanged,
                  onSubmitted: (_) => onSubmit(),
                ),
              ),
              if (hasText)
                IconButton(
                  onPressed: () {
                    controller.clear();
                    onClear?.call();
                  },
                  icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                  tooltip: 'Xóa',
                ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isBusy ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isBusy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Tra'),
              ),
            ],
          ),
        );
      },
    );
  }
}
