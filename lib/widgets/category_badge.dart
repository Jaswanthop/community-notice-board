import 'package:flutter/material.dart';

import '../models/notice_category.dart';

class CategoryBadge extends StatelessWidget {
  const CategoryBadge({super.key, required this.category, this.dense = false});

  final NoticeCategory category;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final foreground = category.foregroundFor(brightness);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: category.backgroundFor(brightness),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(category.icon, size: dense ? 13 : 15, color: foreground),
          const SizedBox(width: 5),
          Text(
            category.label,
            style: TextStyle(
              fontSize: dense ? 11 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
