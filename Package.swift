// swift-tools-version:5.3
//
//  Package.swift
//

import PackageDescription

let package = Package(
    name: "JSONModel",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v9),
        .tvOS(.v9),
        .watchOS(.v2)
    ],
    products: [
        .library(name: "JSONModel",
                 targets: ["JSONModel"])
    ],
    targets: [
        .target(
            name: "JSONModel",
            path: "JSONModel",
            exclude: [
                "Info.plist",
            ],
            sources: [
                "JSONModel",
                "JSONModelNetworking",
                "JSONModelTransformations"
            ],
            publicHeadersPath: "",
            cSettings: [
                .headerSearchPath("JSONModel"),
                .headerSearchPath("JSONModelNetworking"),
                .headerSearchPath("JSONModelTransformations")
            ]
        )
    ]
)
