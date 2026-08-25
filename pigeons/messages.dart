import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    swiftOut: 'ios/review_etiquette/Sources/review_etiquette/Messages.g.swift',
    kotlinOut:
        'android/src/main/kotlin/com/boundfoxstudios/review_etiquette/Messages.g.kt',
    // Without this the generated file carries no package line at all, lands in
    // the Kotlin default package and cannot be resolved from the plugin class.
    kotlinOptions: KotlinOptions(
      package: 'com.boundfoxstudios.review_etiquette',
    ),
    dartPackageName: 'review_etiquette',
  ),
)
@HostApi()
abstract class ReviewEtiquetteHostApi {
  @async
  void requestReview();

  /// Opens this app's listing with the review composer on top.
  @async
  void openStoreListing(String? appStoreId);

  /// Opens the listing of the given app, without the review composer.
  @async
  void showStoreListing(String? appStoreId, String? androidPackageName);
}
