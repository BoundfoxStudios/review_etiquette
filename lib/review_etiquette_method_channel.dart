import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'review_etiquette_platform_interface.dart';

/// An implementation of [ReviewEtiquettePlatform] that uses method channels.
class MethodChannelReviewEtiquette extends ReviewEtiquettePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('review_etiquette');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
