import Testing

@testable import review_etiquette

@Suite("App Store link")
struct AppStoreLinkTests {
  @Test("builds the documented write-review deep link")
  func buildsWriteReviewLink() {
    let url = AppStoreLink.writeReview(appStoreId: "123456789")

    #expect(
      url?.absoluteString == "https://apps.apple.com/app/id123456789?action=write-review")
  }

  @Test("builds the product page link without the review action")
  func buildsProductPageLink() {
    let url = AppStoreLink.productPage(appStoreId: "987654321")

    #expect(url?.absoluteString == "https://apps.apple.com/app/id987654321")
  }

  @Test("rejects an empty id instead of building a broken link")
  func rejectsEmptyId() {
    #expect(AppStoreLink.writeReview(appStoreId: "") == nil)
    #expect(AppStoreLink.productPage(appStoreId: "") == nil)
  }
}

@Suite("Review etiquette plugin")
@MainActor
struct ReviewEtiquettePluginTests {
  @Test("reports no_window_scene when no scene can be resolved")
  func reportsMissingWindowScene() async {
    let plugin = ReviewEtiquettePlugin(registrar: nil)

    do {
      try await plugin.requestReview()
      Issue.record("Expected requestReview to throw without a window scene.")
    } catch let error as PigeonError {
      #expect(error.code == "no_window_scene")
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("reports missing_app_store_id before touching the App Store")
  func reportsMissingAppStoreId() async {
    let plugin = ReviewEtiquettePlugin(registrar: nil)

    do {
      try await plugin.openStoreListing(appStoreId: nil)
      Issue.record("Expected openStoreListing to throw without an id.")
    } catch let error as PigeonError {
      #expect(error.code == "missing_app_store_id")
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("reports invalid_app_store_id for an id that yields no URL")
  func reportsInvalidAppStoreId() async {
    let plugin = ReviewEtiquettePlugin(registrar: nil)

    do {
      try await plugin.openStoreListing(appStoreId: "")
      Issue.record("Expected openStoreListing to throw for an empty id.")
    } catch let error as PigeonError {
      #expect(error.code == "invalid_app_store_id")
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("reports missing_app_store_id when another app has no id")
  func reportsMissingAppStoreIdForAnotherApp() async {
    let plugin = ReviewEtiquettePlugin(registrar: nil)

    do {
      try await plugin.showStoreListing(appStoreId: nil, androidPackageName: "com.example.other")
      Issue.record("Expected showStoreListing to throw without an id.")
    } catch let error as PigeonError {
      #expect(error.code == "missing_app_store_id")
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test("reports invalid_app_store_id when another app's id yields no URL")
  func reportsInvalidAppStoreIdForAnotherApp() async {
    let plugin = ReviewEtiquettePlugin(registrar: nil)

    do {
      try await plugin.showStoreListing(appStoreId: "", androidPackageName: nil)
      Issue.record("Expected showStoreListing to throw for an empty id.")
    } catch let error as PigeonError {
      #expect(error.code == "invalid_app_store_id")
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }
}
