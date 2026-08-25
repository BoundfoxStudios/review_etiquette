import Foundation

enum AppStoreLink {
  /// The documented deep link to an app's store page.
  ///
  /// Apple's own sample builds the bare `/app/id<ID>` form without a locale or
  /// slug, which is the safest string to assemble programmatically.
  static func url(appStoreId: String, action: StoreListingAction) -> URL? {
    guard !appStoreId.isEmpty else {
      return nil
    }

    let query: String
    switch action {
    case .writeReview:
      query = "?action=write-review"
    case .view:
      query = ""
    }

    return URL(string: "https://apps.apple.com/app/id\(appStoreId)\(query)")
  }
}
