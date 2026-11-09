import 'dart:math';

import 'package:flutter/material.dart';

import '../data/demo_notices.dart';
import '../data/notice_store.dart';
import '../models/comment.dart';
import '../models/notice.dart';
import '../models/notice_category.dart';
import '../utils/notice_filters.dart';

/// Single source of truth for the board. Screens listen through [AppScope].
class AppState extends ChangeNotifier {
  AppState({required this.store});

  final NoticeStore store;

  final List<Notice> _notices = <Notice>[];
  final Random _random = Random();
  String _userName = 'Neighbor';
  ThemeMode _themeMode = ThemeMode.system;

  List<Notice> get notices => List<Notice>.unmodifiable(_notices);

  /// Pinned notices first, then newest to oldest.
  List<Notice> get sortedNotices => sortNotices(_notices);

  List<Notice> get savedNotices =>
      sortedNotices.where((notice) => notice.isBookmarked).toList();

  String get userName => _userName;

  ThemeMode get themeMode => _themeMode;

  int get myPostCount =>
      _notices.where((notice) => notice.author == _userName).length;

  int get myCommentCount => _notices.fold<int>(
    0,
    (total, notice) =>
        total + notice.comments.where((c) => c.author == _userName).length,
  );

  Notice? noticeById(String id) {
    for (final notice in _notices) {
      if (notice.id == id) return notice;
    }
    return null;
  }

  Future<void> load() async {
    final stored = store.readNotices();
    _notices
      ..clear()
      ..addAll(stored ?? buildDemoNotices());
    _userName = store.readUserName() ?? 'Neighbor';
    _themeMode = store.readThemeMode();

    if (stored == null) {
      await _persist();
    }
    notifyListeners();
  }

  Future<Notice> createNotice({
    required String title,
    required String body,
    required NoticeCategory category,
    bool isPinned = false,
  }) async {
    final notice = Notice(
      id: _newId(),
      title: title.trim(),
      body: body.trim(),
      author: _userName,
      category: category,
      createdAt: DateTime.now(),
      isPinned: isPinned,
    );
    _notices.add(notice);
    notifyListeners();
    await _persist();
    return notice;
  }

  Future<void> updateNotice(Notice notice) async {
    final index = _notices.indexWhere((item) => item.id == notice.id);
    if (index == -1) return;

    // Keep engagement flags owned by the board (not by the edit form).
    final stored = _notices[index];
    _notices[index] = notice.copyWith(isBookmarked: stored.isBookmarked);
    notifyListeners();
    await _persist();
  }

  Future<void> deleteNotice(String id) async {
    final before = _notices.length;
    _notices.removeWhere((notice) => notice.id == id);
    if (_notices.length == before) return;
    notifyListeners();
    await _persist();
  }

  Future<void> toggleBookmark(String id) async {
    final index = _notices.indexWhere((notice) => notice.id == id);
    if (index == -1) return;
    _notices[index] = _notices[index].copyWith(
      isBookmarked: !_notices[index].isBookmarked,
    );
    notifyListeners();
    await _persist();
  }

  Future<void> togglePin(String id) async {
    final index = _notices.indexWhere((notice) => notice.id == id);
    if (index == -1) return;
    _notices[index] = _notices[index].copyWith(
      isPinned: !_notices[index].isPinned,
    );
    notifyListeners();
    await _persist();
  }

  Future<void> addComment(String noticeId, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final index = _notices.indexWhere((notice) => notice.id == noticeId);
    if (index == -1) return;

    final notice = _notices[index];
    final comment = Comment(
      id: _newId(),
      author: _userName,
      text: trimmed,
      createdAt: DateTime.now(),
    );
    _notices[index] = notice.copyWith(
      comments: <Comment>[...notice.comments, comment],
    );
    notifyListeners();
    await _persist();
  }

  Future<void> setUserName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == _userName) return;
    _userName = trimmed;
    notifyListeners();
    await store.writeUserName(trimmed);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await store.writeThemeMode(mode);
  }

  Future<void> resetToDemo() async {
    _notices
      ..clear()
      ..addAll(buildDemoNotices());
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() => store.writeNotices(_notices);

  String _newId() {
    return '${DateTime.now().microsecondsSinceEpoch}-'
        '${_random.nextInt(1 << 20)}';
  }
}
