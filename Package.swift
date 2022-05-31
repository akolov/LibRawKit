// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LibRaw",
  platforms: [.iOS(.v15), .macOS(.v12)],
  products: [
    .library(name: "LibRaw", targets: ["LibRaw"]),
    .library(name: "LibRawKit", targets: ["LibRawKit"]),
  ],
  targets: [
    .target(
      name: "LibRaw",
      path: ".",
      sources: ["Sources/LibRaw"],
      publicHeadersPath: "libraw",
      cxxSettings: [
        .headerSearchPath("."),
        .headerSearchPath("Sources/LibRaw"),
        .define("LIBRAW_NOTHREADS"),
        .unsafeFlags(["-pthread", "-w"])
      ]
    ),
    .target(
      name: "LibRawKit",
      dependencies: [.target(name: "LibRaw")]
    )
  ]
)
