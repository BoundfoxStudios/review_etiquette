import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:review_etiquette/src/review_state_storage.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

const String timestampKey = 'review_etiquette.lastRequestedAt';
const String versionKey = 'review_etiquette.lastRequestedVersion';

void usePreferences(Map<String, Object> data) {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.withData(data);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => usePreferences(<String, Object>{}));

  group('read', () {
    test('read_nothingStored_returnsNulls', () async {
      final state = await ReviewStateStorage().read();

      expect(state.lastRequestedAt, isNull);
      expect(state.lastRequestedVersion, isNull);
    });

    test('read_storedState_returnsUtcTimestampAndVersion', () async {
      final storedAt = DateTime.utc(2026, 5, 17, 9, 30);
      usePreferences(<String, Object>{
        timestampKey: storedAt.millisecondsSinceEpoch,
        versionKey: '1.4.2',
      });

      final state = await ReviewStateStorage().read();

      expect(state.lastRequestedAt, storedAt);
      expect(state.lastRequestedAt!.isUtc, isTrue);
      expect(state.lastRequestedVersion, '1.4.2');
    });

    test('read_timestampOfWrongType_throwsFormatException', () async {
      usePreferences(<String, Object>{timestampKey: 'not-an-int'});

      await expectLater(
        ReviewStateStorage().read(),
        throwsA(isA<FormatException>()),
      );
    });

    test('read_timestampOutOfRange_throwsFormatException', () async {
      usePreferences(<String, Object>{timestampKey: 8640000000000001});

      await expectLater(
        ReviewStateStorage().read(),
        throwsA(isA<FormatException>()),
      );
    });

    test('read_versionOfWrongType_throwsFormatException', () async {
      usePreferences(<String, Object>{versionKey: 42});

      await expectLater(
        ReviewStateStorage().read(),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('writeRequested', () {
    test('writeRequested_localClock_storesTheInstantAsUtc', () async {
      // Writing from a local clock and reading back must yield the same instant
      // with the UTC flag set: DateTime equality also compares that flag, so a
      // local read would break every cooldown comparison.
      final localNow = DateTime.parse('2026-05-17T09:30:00+02:00').toLocal();
      final storage = ReviewStateStorage();

      await withClock(
        Clock.fixed(localNow),
        () => storage.writeRequested('1.4.2'),
      );

      final state = await storage.read();
      expect(state.lastRequestedAt, DateTime.utc(2026, 5, 17, 7, 30));
      expect(state.lastRequestedVersion, '1.4.2');
    });
  });
}
