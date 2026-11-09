import 'package:community_notice_board/models/comment.dart';
import 'package:community_notice_board/models/notice.dart';
import 'package:community_notice_board/models/notice_category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Notice', () {
    final createdAt = DateTime(2026, 3, 14, 9, 30);
    final notice = Notice(
      id: 'notice-1',
      title: 'Bake sale',
      body: 'Sunday at the community hall.',
      author: 'Alex Morgan',
      category: NoticeCategory.events,
      createdAt: createdAt,
      isPinned: true,
      isBookmarked: true,
      comments: <Comment>[
        Comment(
          id: 'comment-1',
          author: 'Sam Lee',
          text: 'See you there!',
          createdAt: createdAt.add(const Duration(hours: 1)),
        ),
      ],
    );

    test('serialises and restores every field', () {
      final restored = Notice.fromJson(notice.toJson());

      expect(restored, notice);
      expect(restored.comments.single.text, 'See you there!');
    });

    test('copyWith keeps the id and only changes given fields', () {
      final updated = notice.copyWith(title: 'Big bake sale', isPinned: false);

      expect(updated.id, notice.id);
      expect(updated.title, 'Big bake sale');
      expect(updated.isPinned, isFalse);
      expect(updated.body, notice.body);
      expect(updated.isBookmarked, isTrue);
    });

    test('falls back to general for unknown categories', () {
      final restored = Notice.fromJson(<String, dynamic>{
        ...notice.toJson(),
        'category': 'not-a-category',
      });

      expect(restored.category, NoticeCategory.general);
    });

    test('tolerates missing optional fields', () {
      final restored = Notice.fromJson(<String, dynamic>{'id': 'bare'});

      expect(restored.title, 'Untitled notice');
      expect(restored.author, 'Anonymous');
      expect(restored.comments, isEmpty);
      expect(restored.isPinned, isFalse);
    });
  });
}
