import Flutter

public class ReviewEtiquettePlugin: NSObject, FlutterPlugin, ReviewEtiquetteHostApi {
  // Flutter's own header asks plugins not to hold a strong reference to the view controller,
  // and the registrar is the only supported way to reach the visible scene at call time.
  private weak var registrar: FlutterPluginRegistrar?

  init(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
    super.init()
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let plugin = ReviewEtiquettePlugin(registrar: registrar)
    ReviewEtiquetteHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: plugin)
    registrar.publish(plugin)
  }

  func requestReview() async throws {
    throw PigeonError(
      code: "unimplemented", message: "requestReview is not implemented yet.", details: nil)
  }

  func openStoreListing(appStoreId: String?) async throws {
    throw PigeonError(
      code: "unimplemented", message: "openStoreListing is not implemented yet.", details: nil)
  }
}
