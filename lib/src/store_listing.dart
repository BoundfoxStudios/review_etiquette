import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'messages.g.dart';
import 'review_etiquette_exception.dart';

/// Opens the store page for this app through [api].
///
/// Unlike a review request this is user initiated, so it reports failure by
/// throwing instead of staying silent: a button that does nothing is worse
/// than an error the app can react to.
Future<void> openStoreListing(
  ReviewEtiquetteHostApi api, {
  String? appStoreId,
}) async {
  _requireAppStoreIdOnIos(appStoreId);

  // A null package name is what the native side reads as this app.
  await _translatingFailures(
    () =>
        api.openStoreListing(appStoreId, null, StoreListingAction.writeReview),
  );
}

/// Opens the store page of the app named by [appStoreId] and
/// [androidPackageName] through [api], without the review composer.
///
/// Throws like [openStoreListing], and for the same reason.
Future<void> showStoreListing(
  ReviewEtiquetteHostApi api, {
  String? appStoreId,
  String? androidPackageName,
}) async {
  _requireAppStoreIdOnIos(appStoreId);

  // Without the package name Android would fall back to this app's own
  // listing, which is a silent wrong result rather than a visible failure.
  if (defaultTargetPlatform == TargetPlatform.android &&
      androidPackageName == null) {
    throw const ReviewEtiquetteException(
      'androidPackageName is required on Android. Pass the application id of '
      'the app to show, for example com.example.app.',
    );
  }

  await _translatingFailures(
    () => api.openStoreListing(
      appStoreId,
      androidPackageName,
      StoreListingAction.view,
    ),
  );
}

// Failing here rather than natively keeps the message useful: on Android the
// id is genuinely unused, so its absence only becomes a bug on iOS, where a
// developer testing on Android would never see it.
void _requireAppStoreIdOnIos(String? appStoreId) {
  if (defaultTargetPlatform == TargetPlatform.iOS && appStoreId == null) {
    throw const ReviewEtiquetteException(
      'appStoreId is required on iOS. Pass the numeric id from your App Store '
      'product page URL, for example 123456789.',
    );
  }
}

Future<void> _translatingFailures(Future<void> Function() call) async {
  try {
    await call();
  } on PlatformException catch (error) {
    throw ReviewEtiquetteException(
      'Could not open the store listing: ${error.message ?? error.code}',
    );
  } on MissingPluginException {
    throw const ReviewEtiquetteException(
      'Could not open the store listing: this platform has no implementation.',
    );
  }
}
