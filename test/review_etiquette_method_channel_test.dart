import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:review_etiquette/review_etiquette_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelReviewEtiquette platform = MethodChannelReviewEtiquette();
  const MethodChannel channel = MethodChannel('review_etiquette');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
