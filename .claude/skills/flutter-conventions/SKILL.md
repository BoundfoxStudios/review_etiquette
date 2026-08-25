---
name: flutter-conventions
description: Use for Flutter and Dart development - widgets, state, tests, pub. Contains this project's Flutter conventions.
---

# Flutter conventions

A short form of the official Flutter AI rules:

- Null-safe; use `!` only where non-null is guaranteed
- Small, composed widgets: private widget classes instead of helper methods,
  `const` constructors where possible, no expensive work in `build()`,
  `ListView.builder` for long lists
- State: built-in solutions (`ValueNotifier`/`ChangeNotifier` with builders,
  streams and futures); third-party packages only on explicit request
- Routing: go_router for deep-linkable navigation, `Navigator` for
  short-lived dialogs
- `package:flutter_lints` in `analysis_options.yaml`; tests with
  `flutter_test`/`package:test`, fakes before mocks
- Full rules: https://github.com/flutter/flutter/blob/main/docs/rules/rules.md

<!-- TODO: Add your own conventions (state management, testing setup, ...) -->
