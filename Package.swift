// swift-tools-version:5.0
import PackageDescription

let package = Package(
  name: "RxCoreData",
  platforms: [
    .iOS(.v9),
    .macOS(.v10_12)
  ],
  products: [
    .library(name: "RxCoreData", targets: ["RxCoreData"]),
  ],
  dependencies: [
    .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.0"))
  ],
  targets: [
    .target(
        name: "RxCoreData",
        dependencies: ["RxSwift", "RxCocoa"],
        path: "Sources"),
  ]
)
