import 'package:flutter/material.dart';

import '../models/notice_category.dart';

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final NoticeCategory? selected;
  final ValueChanged<NoticeCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          _FilterChip(
            label: 'All',
            icon: Icons.grid_view_rounded,
            accent: Theme.of(context).colorScheme.primary,
            isSelected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final category in NoticeCategory.values) ...<Widget>[
            const SizedBox(width: 8),
            _FilterChip(
              label: category.label,
              icon: category.icon,
              accent: category.foregroundFor(Theme.of(context).brightness),
              isSelected: selected == category,
              onTap: () => onSelected(category),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.accent,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color accent;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? accent : scheme.onSurfaceVariant,
      ),
      label: Text(label),
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? accent : scheme.onSurfaceVariant,
      ),
      backgroundColor: scheme.surfaceContainerLow,
      selectedColor: accent.withValues(alpha: 0.14),
      side: BorderSide(
        color: isSelected
            ? accent.withValues(alpha: 0.45)
            : scheme.outlineVariant,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }
}
