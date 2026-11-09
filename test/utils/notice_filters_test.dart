import 'package:community_notice_board/models/notice.dart';
import 'package:community_notice_board/models/notice_category.dart';
import 'package:community_notice_board/utils/notice_filters.dart';
import 'package:flutter_test/flutter_test.dart';

Notice _notice({
  required String id,
  required String title,
  String body = 'Body',
  String author = 'Author',
  NoticeCategory category = NoticeCategory.general,
  required DateTime createdAt,
  bool isPinned = false,
}) {
  return Notice(
    id: id,
    title: title,
    body: body,
    author: author,
    category: category,
    createdAt: createdAt,
    isPinned: isPinned,
  );
}

void main() {
  final now = DateTime(2026, 5, 20, 12);

  final notices = <Notice>[
    _notice(
      id: 'older',
      title: 'Yoga in the park',
      body: 'Bring a mat',
      author: 'Karan',
      category: NoticeCategory.events,
      createdAt: now.subtract(const Duration(days: 3)),
    ),
    _notice(
      id: 'newer',
      title: 'Plumber available',
      body: 'Call Sam',
      author: 'Meera',
      category: NoticeCategory.services,
      createdAt: now.subtract(const Duration(hours: 2)),
    ),
    _notice(
      id: 'pinned',
      title: 'Street clean-up',
      body: 'Saturday morning',
      author: 'Priya',
      createdAt: now.subtract(const Duration(days: 10)),
      isPinned: true,
    ),
  ];

  group('sortNotices', () {
    test('puts pinned notices first then sorts by date', () {
      final sorted = sortNotices(notices);

      expect(sorted.map((notice) => notice.id), <String>[
        'pinned',
        'newer',
        'older',
      ]);
    });
  });

  group('filterNotices', () {
    test('matches titles case-insensitively', () {
      final result = filterNotices(notices, query: 'YOGA');

      expect(result.single.id, 'older');
    });

    test('matches body and author as well', () {
      expect(filterNotices(notices, query: 'call sam').single.id, 'newer');
      expect(filterNotices(notices, query: 'priya').single.id, 'pinned');
    });

    test('filters by category', () {
      final result = filterNotices(
        notices,
        category: NoticeCategory.services,
      );

      expect(result.single.id, 'newer');
    });

    test('combines query and category', () {
      expect(
        filterNotices(notices, query: 'mat', category: NoticeCategory.events),
        hasLength(1),
      );
      expect(
        filterNotices(notices, query: 'mat', category: NoticeCategory.safety),
        isEmpty,
      );
    });

    test('ignores blank queries', () {
      expect(filterNotices(notices, query: '   '), hasLength(3));
    });
  });
}
