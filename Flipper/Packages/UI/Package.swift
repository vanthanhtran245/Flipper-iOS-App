// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "UI",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "UI",
            targets: ["UI"])
    ],
    dependencies: [
        .package(
            name: "Core",
            path: "../Core"),
        .package(
            name: "Analytics",
            path: "../Analytics"),
        .package(
            name: "Lottie",
            url: "https://github.com/airbnb/lottie-ios.git",
            from: "3.3.0"),
        .package(
            name: "MarkdownUI",
            url: "https://github.com/tonyfreeman/MarkdownUI.git",
            from: "1.1.1")
    ],
    targets: [
        .target(
            name: "UI",
            dependencies: [
                "Core",
                "Lottie",
                "Analytics",
                "MarkdownUI"
            ],
            path: "Sources"),
        .testTarget(
            name: "UITests",
            dependencies: ["UI"],
            path: "Tests")
    ]
)
