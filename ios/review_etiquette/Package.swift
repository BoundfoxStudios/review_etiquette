// swift-tools-version: 6.0

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
            ],
            swiftSettings: [.swiftLanguageMode(.v6)]
        )
    ]
)
