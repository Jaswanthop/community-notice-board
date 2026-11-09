import 'package:flutter/material.dart';

import 'app.dart';
import 'data/notice_store.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = await NoticeStore.open();
  final state = AppState(store: store);
  await state.load();

  runApp(NoticeBoardApp(state: state));
}
