import ComposableArchitecture
import XCTestDynamicOverlay

extension DependencyValues {
    public var buildkite: APIClient {
        get { self[BuildkiteKey.self] }
        set { self[BuildkiteKey.self] = newValue }
    }

    private enum BuildkiteKey: DependencyKey {
        static let liveValue: APIClient = .live
        static let testValue: APIClient = .unimplemented
    }

    public var organization: OrganizationStorage {
        get { self[OrganizationKey.self] }
        set { self[OrganizationKey.self] = newValue }
    }

    private enum OrganizationKey: DependencyKey {
        static let liveValue: OrganizationStorage = .live
        static let testValue: OrganizationStorage = .unimplemented
    }
}

public struct OrganizationStorage: Sendable {
    private var generate: @Sendable () -> String

    /// A generator that returns a constant organization slug.
    ///
    /// - Parameter organization: An organization slug to return.
    /// - Returns: A generator that always returns the given organization.
    public static func constant(_ organization: String) -> Self {
        Self { organization }
    }

    /// A generator that returns a stored value from under the hood.
    public static let live = Self { "asky" }

    /// A generator that calls `XCTFail` when it is invoked.
    public static let unimplemented = Self {
        XCTFail(#"Unimplemented: @Dependency(\.organization)"#)
        return "aaronsky"
    }

    /// The current organization.
    public var organization: String {
        get { self.generate() }
        set { self.generate = { newValue } }
    }

    public func callAsFunction() -> String {
        self.generate()
    }
}
