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
                "AgentsFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "APIClient",
            dependencies: [
                "GraphQLHelpers",
                .product(name: "Buildkite", package: "buildkite-swift"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "APIClientTests",
            dependencies: [
                "APIClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "AuthenticationClient",
            dependencies: [
                "APIClient",
                .product(name: "Buildkite", package: "buildkite-swift"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "AuthenticationClientTests",
            dependencies: [
                "AuthenticationClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
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
                "AppFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
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
                "BuildsFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
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
                "ChangelogFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
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
                "EmojiClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(name: "Formatters"),
        .testTarget(
            name: "FormattersTests",
            dependencies: [
                "Formatters",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
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
                "GraphQLHelpers",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "LoginFeature",
            dependencies: [
                "APIClient",
                "AuthenticationClient",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "LoginFeatureTests",
            dependencies: [
                "LoginFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
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
                "PipelinesFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "ProfileFeature",
            dependencies: [
                "APIClient",
                "AuthenticationClient",
                "ChangelogFeature",
                "GraphQLHelpers",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "ProfileFeatureTests",
            dependencies: [
                "ProfileFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
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
                "TeamsFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
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
                "UsersFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
    ]
)
