// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BlackjackTrainer",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "BlackjackTrainer",
            targets: ["BlackjackTrainer"]
        ),
        .executable(
            name: "BlackjackTrainerApp",
            targets: ["BlackjackTrainerApp"]
        ),
    ],
    dependencies: [
        // No external dependencies - pure SwiftUI implementation
    ],
    targets: [
        .target(
            name: "BlackjackTrainer",
            dependencies: []
        ),
        .executableTarget(
            name: "BlackjackTrainerApp",
            dependencies: ["BlackjackTrainer"]
        ),
        .testTarget(
            name: "BlackjackTrainerTests",
            dependencies: ["BlackjackTrainer"]
        ),
    ]
)