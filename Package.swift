// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ALTENLogger",
    platforms: [.iOS(.v11), .macOS(.v10_12), .tvOS(.v12), .watchOS(.v7)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ALTENLoggerConsole",
            targets: ["ALTENLogger"]),
        .library(
            name: "ALTENLoggerFirebase",
            targets: ["ALTENLoggerFirebase"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "8.10.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ALTENLoggerCore",
            dependencies: [
                .product(name: "Logging", package: "swift-log")
            ]),
        .target(
            name: "ALTENLogger",
            dependencies: [
                "ALTENLoggerCore"
            ]),
        .target(
            name: "ALTENLoggerFirebase",
            dependencies: [
                "ALTENLogger",
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk")
            ])
    ]
)
