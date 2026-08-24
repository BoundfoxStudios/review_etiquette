// swift-tools-version: 5.9
//
// Deliberately not Swift 6 language mode: Pigeon 28 generates a message handler that captures
// the non-Sendable `api` and `reply` inside `Task { @MainActor in }`, and generated code cannot
// be fixed by hand. Pigeon ships its own packages at 5.9 for the same reason. Revisit when
// Pigeon's generated Swift is language-mode clean.

import PackageDescription

let package = Package(
    name: "review_etiquette",
    platforms: [
        .iOS("16.0")
    ],
    products: [
        .library(name: "review-etiquette", targets: ["review_etiquette"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "review_etiquette",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                // Apple's privacy manifest rule is per bundle and cannot be delegated to the
                // host app, so the file ships even though every array in it is empty.
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
