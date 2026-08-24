/// Decides when to ask for an in-app review, and asks.
///
/// Ask after your app delivered value rather than on launch, and let the
/// package hold the cooldown that both stores expect:
///
/// ```dart
/// final etiquette = ReviewEtiquette(appVersion: '1.4.2');
/// final outcome = await etiquette.requestReview();
/// ```
library;

export 'src/review_etiquette_exception.dart';
export 'src/review_request_outcome.dart';
