// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "demofetchserver",
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/Kitura.git", from: "2.5.0"),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", from: "1.7.1"),
        .package(url: "https://github.com/IBM-Swift/Kitura-StencilTemplateEngine.git",from: "1.10.0"),        
    ],
    targets: [
        .target(
            name: "demofetchserver",
            dependencies: ["Kitura","HeliumLogger","KituraStencil"]),
    ]
)
