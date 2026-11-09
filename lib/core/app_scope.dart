import 'package:flutter/widgets.dart';

import '../state/app_state.dart';

/// Makes the shared [AppState] available to the widget tree and rebuilds
/// dependents whenever the board changes.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found above this widget.');
    return scope!.notifier!;
  }
}
