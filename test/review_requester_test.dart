import 'package:clock/clock.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:review_etiquette/review_etiquette.dart';
import 'package:review_etiquette/src/review_requester.dart';
import 'package:review_etiquette/src/review_state_storage.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'fake_host_api.dart';

const String timestampKey = 'review_etiquette.lastRequestedAt';
const String versionKey = 'review_etiquette.lastRequestedVersion';
final DateTime now = DateTime.utc(2026, 8, 24, 12);

ReviewRequester requesterWith({
  Map<String, Object> stored = const <String, Object>{},
  String appVersion = '1.4.2',
  Duration cooldown = const Duration(days: 120),
  FakeHostApi? api,
}) {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData(Map<String, Object>.of(stored));

  return ReviewRequester(
    appVersion: appVersion,
    cooldown: cooldown,
    api: api ?? FakeHostApi(),
    storage: ReviewStateStorage(),
  );
}

Map<String, Object> askedAt(DateTime when, {String version = '1.4.2'}) =>
    <String, Object>{
      timestampKey: when.millisecondsSinceEpoch,
      versionKey: version,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('predicate', () {
    test('requestReview_neverAskedBefore_asks', () async {
      final api = FakeHostApi();
      final requester = requesterWith(api: api);

      final outcome = await withClock(
        Clock.fixed(now),
        requester.requestReview,
      );

      expect(outcome, ReviewRequestOutcome.requested);
      expect(api.requestReviewCalls, 1);
    });

    test('requestReview_cooldownNotElapsed_skipsWithoutAsking', () async {
      final api = FakeHostApi();
      final requester = requesterWith(
        stored: askedAt(
          now.subtract(const Duration(days: 119)),
          version: '1.0.0',
        ),
        api: api,
      );

      final outcome = await withClock(
        Clock.fixed(now),
        requester.requestReview,
      );

      expect(outcome, ReviewRequestOutcome.skippedTooSoon);
      expect(api.requestReviewCalls, 0);
    });

    test('requestReview_cooldownExactlyElapsed_asks', () async {
      final requester = requesterWith(
        stored: askedAt(
          now.subtract(const Duration(days: 120)),
          version: '1.0.0',
        ),
      );

      final outcome = await withClock(
        Clock.fixed(now),
        requester.requestReview,
      );

      expect(outcome, ReviewRequestOutcome.requested);
    });

    test('requestReview_sameVersionAlreadyAsked_skips', () async {
      final requester = requesterWith(
        stored: askedAt(now.subtract(const Duration(days: 400))),
      );

      final outcome = await withClock(
        Clock.fixed(now),
        requester.requestReview,
      );

      expect(outcome, ReviewRequestOutcome.skippedSameVersion);
    });

    test('requestReview_bothConditionsFail_reportsCooldownFirst', () async {
      final requester = requesterWith(stored: askedAt(now));

      final outcome = await withClock(
        Clock.fixed(now),
        requester.requestReview,
      );

      expect(outcome, ReviewRequestOutcome.skippedTooSoon);
    });

    test('requestReview_storedTimestampInTheFuture_asks', () async {
      final requester = requesterWith(
        stored: askedAt(now.add(const Duration(days: 365)), version: '1.0.0'),
      );

      final outcome = await withClock(
        Clock.fixed(now),
        requester.requestReview,
      );

      expect(outcome, ReviewRequestOutcome.requested);
    });

    test('requestReview_zeroCooldown_stillHonoursTheVersion', () async {
      final requester = requesterWith(
        stored: askedAt(now),
        cooldown: Duration.zero,
      );

      final outcome = await withClock(
        Clock.fixed(now),
        requester.requestReview,
      );

      expect(outcome, ReviewRequestOutcome.skippedSameVersion);
    });
  });

  group('recording', () {
    test('requestReview_asked_recordsTimestampAndVersion', () async {
      final requester = requesterWith();

      await withClock(Clock.fixed(now), requester.requestReview);

      final state = await ReviewStateStorage().read();
      expect(state.lastRequestedAt, now);
      expect(state.lastRequestedVersion, '1.4.2');
    });

    test('requestReview_nativeCallFailed_recordsNothing', () async {
      final api = FakeHostApi()
        ..failWith = PlatformException(code: 'no_activity');
      final requester = requesterWith(api: api);

      final outcome = await withClock(
        Clock.fixed(now),
        requester.requestReview,
      );

      expect(outcome, ReviewRequestOutcome.unavailable);
      final state = await ReviewStateStorage().read();
      expect(state.lastRequestedAt, isNull);
      expect(state.lastRequestedVersion, isNull);
    });
  });

  group('failures', () {
    test('requestReview_missingPluginImplementation_isUnavailable', () async {
      final api = FakeHostApi()..failWith = MissingPluginException();
      final requester = requesterWith(api: api);

      final outcome = await withClock(
        Clock.fixed(now),
        requester.requestReview,
      );

      expect(outcome, ReviewRequestOutcome.unavailable);
    });

    test('requestReview_storedTimestampOfWrongType_isUnavailable', () async {
      final api = FakeHostApi();
      final requester = requesterWith(
        stored: <String, Object>{timestampKey: 'not-an-int'},
        api: api,
      );

      final outcome = await withClock(
        Clock.fixed(now),
        requester.requestReview,
      );

      expect(outcome, ReviewRequestOutcome.unavailable);
      expect(api.requestReviewCalls, 0);
    });

    test('requestReview_nativeCallThrewAnError_isUnavailable', () async {
      // Not an Exception: shared_preferences_android deliberately rethrows a
      // device side ClassCastException as a bare TypeError, so an `on Exception`
      // clause would let it escape into the caller's success handler.
      final api = FakeHostApi()..failWith = StateError('boom');
      final requester = requesterWith(api: api);

      final outcome = await withClock(
        Clock.fixed(now),
        requester.requestReview,
      );

      expect(outcome, ReviewRequestOutcome.unavailable);
    });

    test('requestReview_errorInCriticalSection_releasesTheMutex', () async {
      final failing = FakeHostApi()..failWith = StateError('boom');
      final first = requesterWith(api: failing);
      await withClock(Clock.fixed(now), first.requestReview);

      final second = requesterWith();
      final outcome = await withClock(Clock.fixed(now), second.requestReview);

      expect(outcome, ReviewRequestOutcome.requested);
    }, timeout: const Timeout(Duration(seconds: 5)));
  });

  group('concurrency', () {
    test('requestReview_twoCallsAtOnce_asksExactlyOnce', () async {
      final api = FakeHostApi();
      final requester = requesterWith(api: api);

      await withClock(Clock.fixed(now), () async {
        final outcomes = await Future.wait(<Future<ReviewRequestOutcome>>[
          requester.requestReview(),
          requester.requestReview(),
        ]);

        expect(outcomes, <ReviewRequestOutcome>[
          ReviewRequestOutcome.requested,
          ReviewRequestOutcome.skippedTooSoon,
        ]);
      });

      expect(api.requestReviewCalls, 1);
    });
  });
}
