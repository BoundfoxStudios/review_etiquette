
import 'review_etiquette_platform_interface.dart';

class ReviewEtiquette {
  Future<String?> getPlatformVersion() {
    return ReviewEtiquettePlatform.instance.getPlatformVersion();
  }
}
