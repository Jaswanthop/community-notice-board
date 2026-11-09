import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notice.dart';

/// Thin persistence layer over [SharedPreferences].
///
/// Notices are stored as a JSON string, settings as plain primitives. Keeping
/// the storage behind a small class makes it easy to swap in a database later.
class NoticeStore {
  NoticeStore(this._preferences);

  final SharedPreferences _preferences;

  static const String _noticesKey = 'notice_board.notices.v1';
  static const String _userNameKey = 'notice_board.user_name';
  static const String _themeModeKey = 'notice_board.theme_mode';

  static Future<NoticeStore> open() async {
    return NoticeStore(await SharedPreferences.getInstance());
  }

  /// Returns `null` when nothing has been stored yet (first launch).
  List<Notice>? readNotices() {
    final raw = _preferences.getString(_noticesKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Notice.fromJson)
          .toList();
    } on FormatException {
      return null;
    }
  }

  Future<void> writeNotices(List<Notice> notices) {
    final encoded = jsonEncode(
      notices.map((notice) => notice.toJson()).toList(),
    );
    return _preferences.setString(_noticesKey, encoded);
  }

  String? readUserName() => _preferences.getString(_userNameKey);

  Future<void> writeUserName(String name) {
    return _preferences.setString(_userNameKey, name);
  }

  ThemeMode readThemeMode() {
    final stored = _preferences.getString(_themeModeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> writeThemeMode(ThemeMode mode) {
    return _preferences.setString(_themeModeKey, mode.name);
  }
}
