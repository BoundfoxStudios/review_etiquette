import Foundation

enum AppStoreLink {
  /// Apple's own sample builds the bare `/app/id<ID>` form without a locale or
  /// slug, which is the safest string to assemble programmatically.
  private static let productPageBase = "https://apps.apple.com/app/id"

  /// The documented deep link into the App Store review composer.
  static func writeReview(appStoreId: String) -> URL? {
    guard !appStoreId.isEmpty else {
      return nil
    }

    return URL(string: "\(productPageBase)\(appStoreId)?action=write-review")
  }

  static func productPage(appStoreId: String) -> URL? {
    guard !appStoreId.isEmpty else {
      return nil
    }

    return URL(string: "\(productPageBase)\(appStoreId)")
  }
}
