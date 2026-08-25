# review_etiquette

A Flutter plugin that decides **when** to ask for an in-app review, and asks.
The trigger is a success event in the consuming app, never the app launch.

@.claude/general-conventions.md

## How it fits together

Dart decides, native executes. The decision (cooldown elapsed **and** this app
version has not asked) lives in `lib/src/review_requester.dart`; the state is
two keys in `shared_preferences`. The native side is deliberately stateless, so
this package inherits no required-reason declaration of its own and ships an
empty `PrivacyInfo.xcprivacy`.

| Where | What |
| --- | --- |
| `lib/review_etiquette.dart` | The whole public surface. Nothing from `src/` leaks. |
| `lib/src/review_etiquette_base.dart` | Facade. Holds the channel, delegates. |
| `lib/src/review_requester.dart` | The predicate and the recording. |
| `pigeons/messages.dart` | The native contract. Everything `*.g.*` comes from here. |
| `ios/review_etiquette/Sources/review_etiquette/` | Swift, SPM layout. |
| `android/src/main/kotlin/.../` | Kotlin, `ActivityAware`. |

## Commands

```
flutter pub get
flutter analyze
dart format --output=none --set-exit-if-changed .
flutter test
dart run pigeon --input pigeons/messages.dart && dart format lib/src/messages.g.dart
cd example/android && ./gradlew :review_etiquette:test
dart pub global run pana --no-warning
```

The codegen is **two steps**. Pigeon 28 emits Dart that the 3.13 formatter
rewrites, so skipping the `dart format` breaks the format check and with it the
top static-analysis tier. CI verifies the committed output still matches its
input.

## Decisions that will be proposed again

Each of these looks wrong until you know why. Verified on the date given; do not
retry without new evidence.

**Swift 6 language mode is not achievable here** (2026-08-25). Pigeon 28
generates a message handler that captures the non-`Sendable` `api` and `reply`
inside `Task { @MainActor in }`, and generated code cannot be fixed by hand.
Pigeon ships its own packages at `swift-tools-version: 5.9` for the same reason.
Revisit only when Pigeon's generated Swift is language-mode clean.

**The podspec stays, even though SPM is the default** (2026-08-25). SPM is the
default only for **newly created** projects; existing apps stay on CocoaPods
until someone migrates them. `flutter_tools/lib/src/ios/mac.dart` fails the
build for an app on CocoaPods whose plugin ships only a `Package.swift`, and
points the app author at `flutter config --enable-swift-package-manager`.
Dropping the podspec turns a dependency into a migration project.

**A full CocoaPods build of the example is impossible** (2026-08-25). The
example's `project.pbxproj` references `FlutterGeneratedPluginSwiftPackage`, so
xcodebuild resolves SPM packages even with `FLUTTER_SWIFT_PACKAGE_MANAGER=false`,
and our `Package.swift` points at `../FlutterFramework`, which exists only inside
Flutter's SPM symlink farm. The run dies with "the package at
.../ios/FlutterFramework cannot be accessed". That is not a podspec problem.
Verify the podspec with `pod lib lint ios/review_etiquette.podspec --quick
--allow-warnings` instead; `--quick` is required, or the lint resolves `Flutter`
against the stale trunk pod.

**`meta` is a runtime dependency although no hand-written code imports it**
(2026-08-25). The generated Pigeon output imports it, and `pub publish` rejects
an undeclared import. The analyzer never sees it because `analysis_options.yaml`
excludes `**/*.g.dart`, and pana still reports 160/160. Removing it breaks
publishing, not the build.

**Android tests need no Robolectric** (2026-08-24). `ReviewFlow` hands every
`addOnCompleteListener` an explicit executor, which keeps the Play tasks off the
main looper, and `ReviewException(int)` is constructible while `ReviewInfo` is
mockable. The `FakeReviewManager` from the Play artifact is unusable in a JVM
test: it calls `new Intent()`, `Build.VERSION.SDK_INT` and
`PendingIntent.getBroadcast()`. JUnit 5 stays.

**The store listing deliberately has two names** (2026-08-25). Dart rejects a
static and an instance member of the same name
(`conflicting_static_and_instance`), so the instance form stayed
`openStoreListing` and the static one is `ReviewEtiquette.showStoreListing`.
Both exist: the instance form so a consumer holding the object through
dependency injection gets the whole surface, the static one because a "rate this
app" button needs neither an app version nor a cooldown.

A **top-level** `openStoreListing` would keep one name for both, since the
conflict is a class-scope rule only. It was rejected on purpose: the library is
exported wholesale, so the name would land in every file that imports the
package, and a bare `openStoreListing(...)` at a call site names no package
while `ReviewEtiquette.showStoreListing(...)` does. The second verb is the
price for that.

**No `screenshots:` entry in the pubspec.** It earns no pub.dev points and can
cost the ten points for the example. The README image is a different thing and
is fine.

## Footguns

**`requestReview()` catches everything, on purpose.** `on Exception` is not
enough: `shared_preferences` documents `TypeError` on `getInt`, and
`shared_preferences_android` deliberately converts a device-side
`ClassCastException` into a bare `TypeError`, which extends `Error`. The
`// ignore: avoid_catches_without_on_clauses, avoid_catching_errors` in
`review_requester.dart` is required, not sloppiness, because those two lints are
enabled repo-wide. The mutex is released in `finally` for the same reason: it is
process wide, so one escaped `Error` would hang every later call.

**Three iOS floors must move together.** `ios/review_etiquette.podspec`,
`ios/review_etiquette/Package.swift` and all three
`IPHONEOS_DEPLOYMENT_TARGET` entries in
`example/ios/Runner.xcodeproj/project.pbxproj`. CI asserts that the first two
agree. Flutter pins the generated plugin package to its own floor and raises it
only from the Xcode project's setting.

**`flutter pub get` resets that generated floor back to Flutter's own.** The
next Xcode build then fails with "The package product 'review-etiquette'
requires minimum platform version 16.0 for the iOS platform, but this target
supports 15.0". Run `flutter build ios --config-only` afterwards. Building
through the `flutter` command does it for you; building straight from Xcode does
not.

**A sandbox and a Mac cannot share `.dart_tool/package_config.json`.** It holds
absolute paths, so whichever machine ran `flutter pub get` last wins and the
other one fails with "No such file or directory" on the SDK path.

**The pubspec `version:` line must stay bare.** release-please updates it with a
line regex, so a trailing comment or a build number gets mangled.

## Release

release-please cuts the version and the changelog from conventional commits;
`publish.yml` publishes on a `v*` tag through pub.dev's OIDC. Never edit
`version:` or `CHANGELOG.md` by hand for a release.

Two things that bite: a workflow file is armed the moment a push puts it on
`main`, and GitHub resolves a tag push's workflows from the **tagged** commit.
The 0.1.0 release therefore went out with the workflow commits held back, so the
`v0.1.0` tag sits on a commit that carries no `publish.yml`. Its archive was
uploaded by hand; `v1.0.0` is the first tag that actually runs `publish.yml`.

`publish.yml` pins the reusable workflow to an **exact** tag
(`dart-lang/setup-dart/.github/workflows/publish.yml@v1.8.0`), not to `v1`.
Upstream stopped moving that major tag: it still points at v1.7.2, so `@v1`
silently runs an older workflow than the newest release. Check the tag by hand
when bumping actions. This is a workaround for dart-lang/setup-dart#191; once
upstream moves `v1` again, go back to `@v1` and drop this paragraph.

`release-as: "1.0.0"` in `release-please-config.json` forces the next release
pull request to that version. **Take the line out once the pull request is
merged**, or every later release stays 1.0.0. `bump-minor-pre-major` and
`bump-patch-for-minor-pre-major` were dropped in the same pass: both only apply
below 1.0.0, and together they are why a `feat` bumped the patch instead of the
minor up to 0.1.x.

## Verifying by hand

A green test proves nothing about the real prompt: `FakeReviewManager` renders
nothing, and StoreKit reports nothing back. What can actually be observed is in
the README under "Trying it out". The short version: iOS development builds show
the sheet every time and TestFlight never does; Android needs the app in the
signed-in account's Play library once, after which local builds keep working.
