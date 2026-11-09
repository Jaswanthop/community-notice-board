import 'package:community_notice_board/app.dart';
import 'package:community_notice_board/data/notice_store.dart';
import 'package:community_notice_board/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<AppState> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = NoticeStore(await SharedPreferences.getInstance());
    final state = AppState(store: store);
    await state.load();

    await tester.pumpWidget(NoticeBoardApp(state: state));
    await tester.pumpAndSettle();
    return state;
  }

  testWidgets('shows the seeded board', (tester) async {
    await pumpApp(tester);

    expect(find.text('NOTICE BOARD'), findsOneWidget);
    expect(find.text('Community clean-up day this Saturday'), findsOneWidget);
    expect(find.text('New notice'), findsOneWidget);
  });

  testWidgets('search narrows the board', (tester) async {
    await pumpApp(tester);

    await tester.enterText(find.byType(TextField).first, 'yoga');
    await tester.pumpAndSettle();

    expect(find.text('Free beginner yoga at the community hall'), findsOneWidget);
    expect(find.text('Community clean-up day this Saturday'), findsNothing);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    expect(find.text('Community clean-up day this Saturday'), findsOneWidget);
  });

  testWidgets('opens a notice and adds a comment', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Community clean-up day this Saturday'));
    await tester.pumpAndSettle();

    expect(find.text('Notice'), findsOneWidget);
    expect(find.text('Community clean-up day this Saturday'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Comments'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'See you there!');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Send comment'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('See you there!'), findsOneWidget);
  });

  testWidgets('posts a new notice from the composer', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('New notice'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('notice-title-field')),
      'Bake sale on Sunday',
    );
    await tester.enterText(
      find.byKey(const Key('notice-body-field')),
      'Cookies and cakes at the community hall from 10 AM.',
    );
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('submit-notice-button')));
    await tester.pumpAndSettle();

    expect(find.text('Bake sale on Sunday'), findsOneWidget);
    expect(
      find.text('Notice posted to the community board'),
      findsOneWidget,
    );
  });

  testWidgets('switches theme from the profile tab', (tester) async {
    final state = await pumpApp(tester);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(state.themeMode, ThemeMode.dark);
  });
}
