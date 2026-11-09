# Community Notice Board

A neighborhood notice board built with Flutter. Post notices, browse by
category, search the board, bookmark what matters, and keep the conversation
going with comments. Everything is stored locally, so the app works offline.

## Features

- **Board feed** — pinned notices first, then newest. Pull everything into one
  clean, Material 3 list.
- **Categories** — General, Events, Lost & Found, Services, Safety and
  Buy & Sell, each with its own color and icon.
- **Search & filters** — free-text search across titles, bodies and authors,
  combined with category chips.
- **Notice details** — full notice, author, timestamp, comments and a comment
  composer.
- **Post & edit** — validated composer with category picker and "pin to top".
- **Bookmarks** — a dedicated Saved tab backed by local storage.
- **Profile** — edit your display name, switch between system/light/dark theme,
  reset the demo board, and see your post, save and comment counts.
- **Offline-first** — notices, comments, bookmarks and settings persist in
  `shared_preferences`.

## Project structure

```
lib/
├── main.dart                 # Loads state, runs the app
├── app.dart                  # MaterialApp, theming, AppScope wiring
├── core/
│   ├── app_scope.dart        # InheritedNotifier that exposes AppState
│   └── theme.dart            # Light/dark Material 3 themes
├── data/
│   ├── demo_notices.dart     # Seed content for first launch
│   └── notice_store.dart     # shared_preferences persistence
├── models/
│   ├── comment.dart
│   ├── notice.dart
│   └── notice_category.dart
├── screens/
│   ├── home_screen.dart
│   ├── notice_detail_screen.dart
│   ├── notice_form_screen.dart
│   ├── profile_screen.dart
│   └── saved_screen.dart
├── shell/app_shell.dart      # Bottom navigation + post FAB
├── state/app_state.dart      # ChangeNotifier with all board logic
├── utils/
│   ├── formatters.dart
│   └── notice_filters.dart
└── widgets/                  # Cards, chips, search field, empty state
```

## Getting started

Flutter 3.27+ (Dart 3.6+) is required.

```bash
flutter pub get
flutter run
```

Run the test suite and static analysis:

```bash
flutter test
flutter analyze
```

### Platform folders

If you cloned only the source (no `android/`, `ios/`, `web/` folders), generate
the platform runners in place without touching the app code:

```bash
flutter create . --project-name community_notice_board --platforms=android,ios,web
```

## Adding a real backend

`AppState` is the single source of truth and talks to `NoticeStore`. To sync
with a server, replace `NoticeStore` with an API-backed implementation (or wrap
it) and call `load()` after fetching. The UI does not need to change.
