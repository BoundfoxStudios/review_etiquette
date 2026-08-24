import 'package:flutter_test/flutter_test.dart';
import 'package:review_etiquette/review_etiquette.dart';
import 'package:review_etiquette/review_etiquette_platform_interface.dart';
import 'package:review_etiquette/review_etiquette_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockReviewEtiquettePlatform
    with MockPlatformInterfaceMixin
    implements ReviewEtiquettePlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ReviewEtiquettePlatform initialPlatform = ReviewEtiquettePlatform.instance;

  test('$MethodChannelReviewEtiquette is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelReviewEtiquette>());
  });

  test('getPlatformVersion', () async {
    ReviewEtiquette reviewEtiquettePlugin = ReviewEtiquette();
    MockReviewEtiquettePlatform fakePlatform = MockReviewEtiquettePlatform();
    ReviewEtiquettePlatform.instance = fakePlatform;

    expect(await reviewEtiquettePlugin.getPlatformVersion(), '42');
  });
}
