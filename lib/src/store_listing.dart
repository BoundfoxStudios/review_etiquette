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
  ReviewEtiquetteHostApi api,
  String? appStoreId,
) async {
  // Failing here rather than natively keeps the message useful: on Android the
  // id is genuinely unused, so its absence only becomes a bug on iOS, where a
  // developer testing on Android would never see it.
  if (defaultTargetPlatform == TargetPlatform.iOS && appStoreId == null) {
    throw const ReviewEtiquetteException(
      'appStoreId is required on iOS. Pass the numeric id from your App Store '
      'product page URL, for example 123456789.',
    );
  }

  try {
    await api.openStoreListing(appStoreId);
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
