import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_scope.dart';
import 'core/theme.dart';
import 'shell/app_shell.dart';
import 'state/app_state.dart';

class NoticeBoardApp extends StatelessWidget {
  const NoticeBoardApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: ListenableBuilder(
        listenable: state,
        builder: (BuildContext context, _) {
          return MaterialApp(
            title: 'Community Notice Board',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state.themeMode,
            builder: (BuildContext context, Widget? child) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: isDark
                      ? Brightness.light
                      : Brightness.dark,
                  statusBarBrightness: isDark
                      ? Brightness.dark
                      : Brightness.light,
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
