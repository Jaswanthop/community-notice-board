import 'package:community_notice_board/data/notice_store.dart';
import 'package:community_notice_board/models/notice_category.dart';
import 'package:community_notice_board/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<AppState> buildState() async {
    final store = NoticeStore(await SharedPreferences.getInstance());
    final state = AppState(store: store);
    await state.load();
    return state;
  }

  test('seeds the demo board on first launch', () async {
    final state = await buildState();

    expect(state.notices, isNotEmpty);
    expect(state.sortedNotices.first.isPinned, isTrue);
    expect(state.savedNotices, isEmpty);
  });

  test('creates a notice authored by the current user', () async {
    final state = await buildState();

    final created = await state.createNotice(
      title: 'Bake sale',
      body: 'Sunday at the community hall.',
      category: NoticeCategory.events,
    );

    expect(created.author, state.userName);
    expect(state.noticeById(created.id), isNotNull);
    expect(state.notices, hasLength(8));
  });

  test('new notices survive a restart', () async {
    final state = await buildState();
    final created = await state.createNotice(
      title: 'Bake sale',
      body: 'Sunday at the community hall.',
      category: NoticeCategory.events,
    );

    final reloaded = await buildState();

    expect(reloaded.noticeById(created.id)?.title, 'Bake sale');
  });

  test('bookmarks persist across restarts', () async {
    final state = await buildState();
    final target = state.notices.first;

    await state.toggleBookmark(target.id);

    expect(state.savedNotices.single.id, target.id);

    final reloaded = await buildState();
    expect(reloaded.noticeById(target.id)?.isBookmarked, isTrue);
  });

  test('does not reseed after every notice is deleted', () async {
    final state = await buildState();
    for (final notice in state.notices) {
      await state.deleteNotice(notice.id);
    }

    expect(state.notices, isEmpty);

    final reloaded = await buildState();
    expect(reloaded.notices, isEmpty);
  });

  test('adds comments attributed to the current user', () async {
    final state = await buildState();
    await state.setUserName('Alex Morgan');
    final target = state.notices.first;

    await state.addComment(target.id, '  Thanks for sharing!  ');

    final comment = state.noticeById(target.id)!.comments.last;
    expect(comment.text, 'Thanks for sharing!');
    expect(comment.author, 'Alex Morgan');
    expect(state.myCommentCount, 1);
  });

  test('ignores blank comments', () async {
    final state = await buildState();
    final target = state.notices.first;
    final before = target.commentCount;

    await state.addComment(target.id, '   ');

    expect(state.noticeById(target.id)!.commentCount, before);
  });

  test('persists theme mode and user name', () async {
    final state = await buildState();
    await state.setThemeMode(ThemeMode.dark);
    await state.setUserName('Alex Morgan');

    final reloaded = await buildState();

    expect(reloaded.themeMode, ThemeMode.dark);
    expect(reloaded.userName, 'Alex Morgan');
  });

  test('resetToDemo restores the sample board', () async {
    final state = await buildState();
    final target = state.notices.first;
    await state.deleteNotice(target.id);

    await state.resetToDemo();

    expect(state.notices, hasLength(7));
    expect(state.noticeById(target.id), isNotNull);
  });
}
