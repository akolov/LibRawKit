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
  targets: [
    .target(
      name: "CLibRaw",
      dependencies: [
        .target(name: "CZLib")
      ],
      path: ".",
      sources: ["Sources/CLibRaw"],
      publicHeadersPath: "Sources/CLibRaw",
      cxxSettings: [
        .headerSearchPath("."),
        .headerSearchPath("Sources/CLibRaw"),
        .define("LIBRAW_NOTHREADS"),
        .define("NODEPS"),
        .unsafeFlags(["-pthread", "-w"])
      ],
      linkerSettings: [
        .linkedLibrary("c++abi"),
        .linkedLibrary("z")
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
    .systemLibrary(
      name: "CZLib",
      pkgConfig: "libz",
      providers: [
        .brew(["zlib"])
      ]
    )
  ]
)
