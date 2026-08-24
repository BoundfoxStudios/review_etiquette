import 'package:flutter/services.dart';
import 'package:review_etiquette/src/messages.g.dart';

/// Stands in for the generated platform channel.
///
/// The two `pigeonVar_` members are part of the generated class, so their
/// names are not ours to fix.
// ignore_for_file: non_constant_identifier_names
class FakeHostApi implements ReviewEtiquetteHostApi {
  /// How often a review was requested.
  int requestReviewCalls = 0;

  /// Every app store id the store listing was opened with, in order.
  final List<String?> openedWith = <String?>[];

  /// Thrown by both methods when set, including plain [Error]s.
  Object? failWith;

  @override
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  String get pigeonVar_messageChannelSuffix => '';

  @override
  Future<void> requestReview() async {
    requestReviewCalls++;
    _failIfAsked();
  }

  @override
  Future<void> openStoreListing(String? appStoreId) async {
    openedWith.add(appStoreId);
    _failIfAsked();
  }

  void _failIfAsked() {
    // Rethrowing through Error.throwWithStackTrace rather than `throw` keeps
    // Error subtypes available here, which a plain throw statement would not
    // allow us to express.
    if (failWith case final Object error) {
      Error.throwWithStackTrace(error, StackTrace.current);
    }
  }
}
