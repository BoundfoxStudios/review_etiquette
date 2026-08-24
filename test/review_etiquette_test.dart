import 'package:flutter_test/flutter_test.dart';
import 'package:review_etiquette/review_etiquette.dart';

void main() {
  test('constructor_blankAppVersion_throwsArgumentError', () {
    expect(
      () => ReviewEtiquette(appVersion: '   '),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('constructor_emptyAppVersion_throwsArgumentError', () {
    expect(
      () => ReviewEtiquette(appVersion: ''),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('constructor_negativeCooldown_throwsArgumentError', () {
    expect(
      () => ReviewEtiquette(
        appVersion: '1.4.2',
        cooldown: const Duration(days: -1),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('constructor_zeroCooldown_isAllowed', () {
    expect(
      () => ReviewEtiquette(appVersion: '1.4.2', cooldown: Duration.zero),
      returnsNormally,
    );
  });
}
