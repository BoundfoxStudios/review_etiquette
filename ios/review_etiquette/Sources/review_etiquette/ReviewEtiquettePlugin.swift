import Flutter
import StoreKit
import UIKit

public class ReviewEtiquettePlugin: NSObject, FlutterPlugin, ReviewEtiquetteHostApi {
  // Flutter's own header asks plugins not to hold a strong reference to the view
  // controller, and the registrar is the only supported way to reach the visible
  // scene at call time.
  private weak var registrar: FlutterPluginRegistrar?

  init(registrar: FlutterPluginRegistrar?) {
    self.registrar = registrar
    super.init()
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let plugin = ReviewEtiquettePlugin(registrar: registrar)
    ReviewEtiquetteHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: plugin)
    registrar.publish(plugin)
  }

  // Pigeon already dispatches these on the main actor, so the annotation costs no
  // hop and lets the body touch UIKit without an await on every step.
  @MainActor
  func requestReview() async throws {
    // Not UIApplication.shared.connectedScenes.first: that set is unordered, so
    // the pick differs between launches, and it also contains background and
    // offscreen scenes that cannot present anything.
    guard let scene = registrar?.viewController?.view.window?.windowScene else {
      throw PigeonError(
        code: "no_window_scene",
        message: "Could not resolve a window scene to ask for a review in.",
        details: "registrar.viewController.view.window.windowScene was nil.")
    }

    AppStore.requestReview(in: scene)
  }

  @MainActor
  func openStoreListing(
    appStoreId: String?, androidPackageName: String?, action: StoreListingAction
  ) async throws {
    guard let appStoreId else {
      throw PigeonError(
        code: "missing_app_store_id",
        message: "appStoreId is required on iOS.",
        details: "Pass the numeric id from your App Store product page URL.")
    }
    guard let url = AppStoreLink.url(appStoreId: appStoreId, action: action) else {
      throw PigeonError(
        code: "invalid_app_store_id",
        message: "appStoreId did not produce a usable App Store URL.",
        details: appStoreId)
    }

    // No canOpenURL guard: that call is gated on LSApplicationQueriesSchemes
    // while open() is not, so checking first is the classic way to break an
    // https link that would have opened fine.
    guard await UIApplication.shared.open(url) else {
      throw PigeonError(
        code: "store_listing_failed",
        message: "The App Store could not be opened.",
        details: url.absoluteString)
    }
  }
}
