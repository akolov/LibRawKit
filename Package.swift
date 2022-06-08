// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "RawKit",
  platforms: [.iOS(.v15), .macOS(.v12)],
  products: [
    .library(name: "CLibRaw", targets: ["CLibRaw"]),
    .library(name: "RawKit", targets: ["RawKit"]),
  ],
  dependencies: [
    .package(url: "https://github.com/SusanDoggie/libjpeg.git", from: "1.0.3")
  ],
  targets: [
    .target(
      name: "CLibRaw",
      dependencies: [
        .product(name: "libjpeg", package: "libjpeg")
      ],
      path: ".",
      sources: ["Sources/CLibRaw"],
      publicHeadersPath: "Sources/CLibRaw",
      cxxSettings: [
        .headerSearchPath("."),
        .headerSearchPath("Sources/libjpeg/include"),
        .headerSearchPath("Sources/CLibRaw"),
        .define("LIBRAW_NOTHREADS"),
        .define("NO_JASPER"),
        .define("NO_LCMS"),
        .unsafeFlags(["-pthread", "-w"])
      ],
      linkerSettings: [
        .linkedLibrary("c++abi")
      ]
    ),
    .target(
      name: "RawKit",
      dependencies: [.target(name: "CLibRaw")]
    ),
    .testTarget(
      name: "RawKitTests",
      dependencies: [.target(name: "RawKit")]
    ),
  ]
)
