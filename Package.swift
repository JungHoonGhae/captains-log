// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CaptainsLog",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "CaptainsLog",
            path: "Sources/CaptainsLog"
        )
    ]
)
