import 'package:flutter/material.dart';

/// The kinds of notices neighbors can post on the board.
enum NoticeCategory {
  general('General', Icons.campaign_outlined, Color(0xFF0F766E)),
  events('Events', Icons.event_outlined, Color(0xFF7C3AED)),
  lostFound('Lost & Found', Icons.travel_explore_rounded, Color(0xFFEA580C)),
  services('Services', Icons.handyman_outlined, Color(0xFF2563EB)),
  safety('Safety', Icons.shield_outlined, Color(0xFFDC2626)),
  marketplace('Buy & Sell', Icons.sell_outlined, Color(0xFF059669));

  const NoticeCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  /// Readable version of [color] for badges and chips in the given theme.
  Color foregroundFor(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return Color.lerp(color, Colors.white, 0.45)!;
    }
    return color;
  }

  Color backgroundFor(Brightness brightness) {
    return color.withValues(alpha: brightness == Brightness.dark ? 0.22 : 0.12);
  }

  static NoticeCategory fromName(String? name) {
    return values.firstWhere(
      (category) => category.name == name,
      orElse: () => NoticeCategory.general,
    );
  }
}
