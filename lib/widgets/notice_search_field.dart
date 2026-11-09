import 'package:flutter/material.dart';

class NoticeSearchField extends StatelessWidget {
  const NoticeSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Search notices, people, keywords…',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (BuildContext context, TextEditingValue value, _) {
        return TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: hintText,
            fillColor: scheme.surface,
            prefixIcon: Icon(Icons.search_rounded, color: scheme.onSurfaceVariant),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
          ),
        );
      },
    );
  }
}
