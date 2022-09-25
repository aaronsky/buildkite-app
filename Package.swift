// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "BuildkitePackage",
    platforms: [
        .iOS(.v16),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "BuildkitePackage",
            targets: [
                "AppFeature"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/aaronsky/buildkite-swift", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", branch: "protocol-navigation"),
    ],
    targets: [
        .target(
            name: "AgentsFeature",
            dependencies: [
                "APIClient",
                "BuildsFeature",
                "Formatters",
                .product(name: "Buildkite", package: "buildkite-swift"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "AgentsFeatureTests",
            dependencies: [
                "AgentsFeature"
            ]
        ),
        .target(
            name: "APIClient",
            dependencies: [
                "GraphQLHelpers",
                .product(name: "Buildkite", package: "buildkite-swift"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ],
            exclude: ["Secrets.swift.example"]
        ),
        .testTarget(
            name: "APIClientTests",
            dependencies: [
                "APIClient"
            ]
        ),
        .target(
            name: "AppFeature",
            dependencies: [
                "AgentsFeature",
                "APIClient",
                "LoginFeature",
                "PipelinesFeature",
                "ProfileFeature",
                "TeamsFeature",
                "UsersFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "AppFeatureTests",
            dependencies: [
                "AppFeature"
            ]
        ),
        .target(
            name: "BuildsFeature",
            dependencies: [
                "APIClient",
                .product(name: "Buildkite", package: "buildkite-swift"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "BuildsFeatureTests",
            dependencies: [
                "BuildsFeature"
            ]
        ),
        .target(
            name: "ChangelogFeature",
            dependencies: [
                "APIClient",
                "GraphQLHelpers",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "ChangelogFeatureTests",
            dependencies: [
                "ChangelogFeature"
            ]
        ),
        .target(
            name: "EmojiClient",
            dependencies: [
                "APIClient",
                .product(name: "Buildkite", package: "buildkite-swift"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "EmojiClientTests",
            dependencies: [
                "EmojiClient"
            ]
        ),
        .target(name: "Formatters"),
        .testTarget(
            name: "FormattersTests",
            dependencies: [
                "Formatters"
            ]
        ),
        .target(
            name: "GraphQLHelpers",
            dependencies: [
                .product(name: "Buildkite", package: "buildkite-swift")
            ]
        ),
        .testTarget(
            name: "GraphQLHelpersTests",
            dependencies: [
                "GraphQLHelpers"
            ]
        ),
        .target(
            name: "LoginFeature",
            dependencies: [
                "APIClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "LoginFeatureTests",
            dependencies: [
                "LoginFeature"
            ]
        ),
        .target(
            name: "PipelinesFeature",
            dependencies: [
                "APIClient",
                "BuildsFeature",
                "Formatters",
                "GraphQLHelpers",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "PipelinesFeatureTests",
            dependencies: [
                "PipelinesFeature"
            ]
        ),
        .target(
            name: "ProfileFeature",
            dependencies: [
                "APIClient",
                "ChangelogFeature",
                "GraphQLHelpers",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "ProfileFeatureTests",
            dependencies: [
                "ProfileFeature"
            ]
        ),
        .target(
            name: "TeamsFeature",
            dependencies: [
                "APIClient",
                "GraphQLHelpers",
                "UsersFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "TeamsFeatureTests",
            dependencies: [
                "TeamsFeature"
            ]
        ),
        .target(
            name: "UsersFeature",
            dependencies: [
                "APIClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "UsersFeatureTests",
            dependencies: [
                "UsersFeature"
            ]
        ),
    ]
)
