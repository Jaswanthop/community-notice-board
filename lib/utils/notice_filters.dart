import '../models/notice.dart';
import '../models/notice_category.dart';

/// Pinned notices first, then newest to oldest.
List<Notice> sortNotices(Iterable<Notice> notices) {
  final sorted = notices.toList()
    ..sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
  return sorted;
}

/// Filters notices by category and a free-text query that matches the title,
/// body or author (case-insensitive).
List<Notice> filterNotices(
  Iterable<Notice> notices, {
  String query = '',
  NoticeCategory? category,
}) {
  final needle = query.trim().toLowerCase();

  return notices.where((notice) {
    if (category != null && notice.category != category) {
      return false;
    }
    if (needle.isEmpty) {
      return true;
    }
    return notice.title.toLowerCase().contains(needle) ||
        notice.body.toLowerCase().contains(needle) ||
        notice.author.toLowerCase().contains(needle);
  }).toList();
}
