import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:review_etiquette/review_etiquette.dart';
import 'package:review_etiquette/src/messages.g.dart';
import 'package:review_etiquette/src/store_listing.dart' as store_listing;

import 'fake_host_api.dart';

const _openStoreListingChannel =
    'dev.flutter.pigeon.review_etiquette.ReviewEtiquetteHostApi.openStoreListing';

/// Intercepts the real channel and returns the ids it is called with, in order.
///
/// The static entry point builds its own host api, so it cannot be handed a
/// fake; the channel underneath it is the only seam left.
List<Object?> recordStoreListingCalls() {
  const codec = ReviewEtiquetteHostApi.pigeonChannelCodec;
  final appStoreIds = <Object?>[];

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(_openStoreListingChannel, (message) async {
        appStoreIds.add(
          (codec.decodeMessage(message)! as List<Object?>).single,
        );

        return codec.encodeMessage(<Object?>[null]);
      });

  return appStoreIds;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(_openStoreListingChannel, null);
  });

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

  test('showStoreListing_withAppStoreId_reachesThePlatform', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final appStoreIds = recordStoreListingCalls();

    await ReviewEtiquette.showStoreListing(appStoreId: '123456789');

    expect(appStoreIds, <Object?>['123456789']);
  });

  test(
    'showStoreListing_iosWithoutAppStoreId_throwsBeforeReachingThePlatform',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final appStoreIds = recordStoreListingCalls();

      await expectLater(
        ReviewEtiquette.showStoreListing(),
        throwsA(isA<ReviewEtiquetteException>()),
      );
      expect(appStoreIds, isEmpty);
    },
  );
}
