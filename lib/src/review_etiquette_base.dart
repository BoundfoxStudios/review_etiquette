import 'messages.g.dart';
import 'review_etiquette_exception.dart';
import 'review_request_outcome.dart';
import 'review_requester.dart';
import 'review_state_storage.dart';
import 'store_listing.dart' as store_listing;

/// Asks for an in-app review, but only when the platform etiquette allows it.
///
/// Create one instance and call [requestReview] at the moment your app
/// delivered value. Both Apple and Google forbid attaching the system prompt
/// to a button; use [openStoreListing] for that.
class ReviewEtiquette {
  /// Creates a policy for [appVersion] that waits [cooldown] between requests.
  ///
  /// [appVersion] is the user visible version, not a build number that changes
  /// on every CI run, or the version condition never holds. Throws an
  /// [ArgumentError] when it is blank or when [cooldown] is negative.
  ReviewEtiquette({
    required String appVersion,
    Duration cooldown = const Duration(days: 120),
  }) : _requester = ReviewRequester(
         appVersion: _checked(appVersion),
         cooldown: _nonNegative(cooldown),
         api: ReviewEtiquetteHostApi(),
         storage: ReviewStateStorage(),
       );

  final ReviewRequester _requester;

  /// Asks for a review if the cooldown has elapsed and this version has not
  /// asked yet.
  ///
  /// Never throws. Everything that can go wrong, on either platform, comes back
  /// as [ReviewRequestOutcome.unavailable], because a failed review request
  /// must not disturb the flow it is attached to.
  ///
  /// A [ReviewRequestOutcome.requested] result means the request reached the
  /// platform, never that anyone saw a prompt.
  Future<ReviewRequestOutcome> requestReview() => _requester.requestReview();

  /// Opens this app's store page, for a user initiated "rate this app" button.
  ///
  /// [appStoreId] is the numeric id from your App Store product page URL. It is
  /// only used on iOS, where it is required; Android derives the Play Store
  /// listing from the package name.
  ///
  /// Throws a [ReviewEtiquetteException] when the store cannot be opened.
  static Future<void> openStoreListing({String? appStoreId}) =>
      store_listing.openStoreListing(ReviewEtiquetteHostApi(), appStoreId);

  static String _checked(String appVersion) {
    if (appVersion.trim().isEmpty) {
      throw ArgumentError.value(appVersion, 'appVersion', 'must not be blank');
    }

    return appVersion;
  }

  static Duration _nonNegative(Duration cooldown) {
    if (cooldown.isNegative) {
      throw ArgumentError.value(cooldown, 'cooldown', 'must not be negative');
    }

    return cooldown;
  }
}
