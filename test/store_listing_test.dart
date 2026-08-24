import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:review_etiquette/review_etiquette.dart';
import 'package:review_etiquette/src/store_listing.dart' as store_listing;

import 'fake_host_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test(
    'openStoreListing_iosWithoutAppStoreId_throwsBeforeReachingThePlatform',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final api = FakeHostApi();

      await expectLater(
        store_listing.openStoreListing(api, null),
        throwsA(isA<ReviewEtiquetteException>()),
      );
      expect(api.openedWith, isEmpty);
    },
  );

  test('openStoreListing_iosWithAppStoreId_passesItThrough', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final api = FakeHostApi();

    await store_listing.openStoreListing(api, '123456789');

    expect(api.openedWith, <String?>['123456789']);
  });

  test('openStoreListing_androidWithoutAppStoreId_stillOpens', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final api = FakeHostApi();

    await store_listing.openStoreListing(api, null);

    expect(api.openedWith, <String?>[null]);
  });

  test(
    'openStoreListing_platformFailed_throwsReviewEtiquetteException',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final api = FakeHostApi()
        ..failWith = PlatformException(
          code: 'play_store_not_found',
          message: 'No Play Store on this device.',
        );

      await expectLater(
        store_listing.openStoreListing(api, null),
        throwsA(
          isA<ReviewEtiquetteException>().having(
            (error) => error.message,
            'message',
            contains('No Play Store on this device.'),
          ),
        ),
      );
    },
  );

  test(
    'openStoreListing_unsupportedPlatform_throwsReviewEtiquetteException',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      final api = FakeHostApi()..failWith = MissingPluginException();

      await expectLater(
        store_listing.openStoreListing(api, null),
        throwsA(isA<ReviewEtiquetteException>()),
      );
    },
  );
}
