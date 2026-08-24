import 'dart:developer' as developer;

import 'package:clock/clock.dart';

import 'messages.g.dart';
import 'request_mutex.dart';
import 'review_request_outcome.dart';
import 'review_state_storage.dart';

/// Decides whether asking for a review is allowed right now, and asks.
///
/// Kept apart from the public facade so the decision can be tested against a
/// faked platform channel without widening the published surface.
class ReviewRequester {
  /// Creates a requester for [appVersion] that waits [cooldown] between asks.
  ReviewRequester({
    required this.appVersion,
    required this.cooldown,
    required ReviewEtiquetteHostApi api,
    required ReviewStateStorage storage,
  }) : _api = api,
       _storage = storage;

  /// The user visible app version the consumer handed us.
  final String appVersion;

  /// How long to wait between two requests.
  final Duration cooldown;

  final ReviewEtiquetteHostApi _api;
  final ReviewStateStorage _storage;

  /// Asks for a review when both conditions allow it, and never throws.
  Future<ReviewRequestOutcome> requestReview() =>
      runExclusively(_requestReview);

  Future<ReviewRequestOutcome> _requestReview() async {
    try {
      final state = await _storage.read();

      if (!_cooldownElapsed(state.lastRequestedAt)) {
        return ReviewRequestOutcome.skippedTooSoon;
      }
      if (state.lastRequestedVersion == appVersion) {
        return ReviewRequestOutcome.skippedSameVersion;
      }

      await _api.requestReview();
      await _storage.writeRequested(appVersion);

      return ReviewRequestOutcome.requested;
      // Catching Error as well as Exception is deliberate and must stay:
      // shared_preferences_android turns a device side ClassCastException into
      // a bare TypeError, which no `on Exception` clause would hold. An escaped
      // error would surface in the caller's success handler and, because the
      // mutex is process wide, wedge every later call.
      // ignore: avoid_catches_without_on_clauses, avoid_catching_errors
    } catch (error, stackTrace) {
      developer.log(
        'Could not ask for a review.',
        name: 'review_etiquette',
        error: error,
        stackTrace: stackTrace,
      );

      return ReviewRequestOutcome.unavailable;
    }
  }

  bool _cooldownElapsed(DateTime? lastRequestedAt) {
    if (lastRequestedAt == null) {
      return true;
    }

    final now = clock.now().toUtc();
    // A stored instant in the future means the device clock moved backwards.
    // Treating it as elapsed beats locking the user out until it catches up.
    if (lastRequestedAt.isAfter(now)) {
      return true;
    }

    return now.difference(lastRequestedAt) >= cooldown;
  }
}
