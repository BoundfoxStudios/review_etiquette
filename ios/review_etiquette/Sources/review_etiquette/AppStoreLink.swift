import Foundation

enum AppStoreLink {
  /// The documented deep link into the App Store review composer.
  ///
  /// Apple's own sample builds the bare `/app/id<ID>` form without a locale or
  /// slug, which is the safest string to assemble programmatically.
  static func writeReview(appStoreId: String) -> URL? {
    guard !appStoreId.isEmpty else {
      return nil
    }

    return URL(string: "https://apps.apple.com/app/id\(appStoreId)?action=write-review")
  }
}
