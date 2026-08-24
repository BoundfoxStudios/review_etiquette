import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'review_etiquette_method_channel.dart';

abstract class ReviewEtiquettePlatform extends PlatformInterface {
  /// Constructs a ReviewEtiquettePlatform.
  ReviewEtiquettePlatform() : super(token: _token);

  static final Object _token = Object();

  static ReviewEtiquettePlatform _instance = MethodChannelReviewEtiquette();

  /// The default instance of [ReviewEtiquettePlatform] to use.
  ///
  /// Defaults to [MethodChannelReviewEtiquette].
  static ReviewEtiquettePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ReviewEtiquettePlatform] when
  /// they register themselves.
  static set instance(ReviewEtiquettePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
