import ComposableArchitecture
import XCTestDynamicOverlay

extension DependencyValues {
    public var authentication: AuthenticationClient {
        get { self[AuthenticationKey.self] }
        set { self[AuthenticationKey.self] = newValue }
    }

    private enum AuthenticationKey: DependencyKey {
        static let liveValue: AuthenticationClient = .live
        static let testValue: AuthenticationClient = .unimplemented
    }
}
