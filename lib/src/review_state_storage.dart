import 'package:clock/clock.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// When the last review request happened, and which app version made it.
///
/// Both fields are null before the very first request.
typedef ReviewState = ({
  DateTime? lastRequestedAt,
  String? lastRequestedVersion,
});

/// Reads and writes the two values the cooldown decision needs.
class ReviewStateStorage {
  static const String _lastRequestedAtKey = 'review_etiquette.lastRequestedAt';
  static const String _lastRequestedVersionKey =
      'review_etiquette.lastRequestedVersion';
  static const Set<String> _keys = <String>{
    _lastRequestedAtKey,
    _lastRequestedVersionKey,
  };
  static const int _maxMillisecondsSinceEpoch = 8640000000000000;

  SharedPreferencesAsync? _preferences;

  // Constructing this throws when no platform implementation is registered, so
  // it stays out of the ReviewEtiquette constructor and happens on first use.
  SharedPreferencesAsync get _resolved =>
      _preferences ??= SharedPreferencesAsync();

  /// Reads both values in a single platform round trip.
  ///
  /// Throws a [FormatException] when a key holds something this package did not
  /// write. Reading through `getAll` rather than the typed getters keeps that a
  /// decision here rather than a `TypeError` thrown from inside the platform
  /// implementation, which no `on Exception` clause would catch.
  Future<ReviewState> read() async {
    final values = await _resolved.getAll(allowList: _keys);

    return (
      lastRequestedAt: _timestampFrom(values[_lastRequestedAtKey]),
      lastRequestedVersion: _versionFrom(values[_lastRequestedVersionKey]),
    );
  }

  /// Records that [appVersion] asked for a review just now.
  Future<void> writeRequested(String appVersion) async {
    await _resolved.setInt(
      _lastRequestedAtKey,
      clock.now().millisecondsSinceEpoch,
    );
    await _resolved.setString(_lastRequestedVersionKey, appVersion);
  }

  static DateTime? _timestampFrom(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is! int) {
      throw const FormatException('Stored review timestamp is not an integer.');
    }
    if (value.abs() > _maxMillisecondsSinceEpoch) {
      throw FormatException('Stored review timestamp is out of range: $value.');
    }

    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }

  static String? _versionFrom(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is! String) {
      throw const FormatException('Stored review app version is not a string.');
    }

    return value;
  }
}
