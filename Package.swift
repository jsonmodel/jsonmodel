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
                 targets: ["JSONModel", "JSONModelNetworking" , "JSONModelTransformations"])
    ],
    targets: [
        .target(
            name: "JSONModel",
            dependencies: [
                "JSONModelTransformations"
            ],
            path: "JSONModel/JSONModel",
            sources: [
                ""
            ],
            publicHeadersPath: ""
        ),
        .target(
            name: "JSONModelNetworking",
            dependencies: [
                "JSONModel"
            ],
            path: "JSONModel/JSONModelNetworking",
            sources: [
                ""
            ],
            publicHeadersPath: ""
        ),
        .target(
            name: "JSONModelTransformations",
            path: "JSONModel/JSONModelTransformations",
            sources: [
                ""
            ],
            publicHeadersPath: ""
        )
    ]
)
