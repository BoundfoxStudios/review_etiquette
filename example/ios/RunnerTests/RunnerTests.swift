import XCTest

@testable import review_etiquette

// Placeholder so the target keeps at least one test: xcodebuild exits 66 on an
// empty suite, which reads as a green run. Replaced by the Swift Testing suite.
final class RunnerTests: XCTestCase {
  func testPluginModuleLinks() {
    XCTAssertNotNil(ReviewEtiquettePlugin())
  }
}
