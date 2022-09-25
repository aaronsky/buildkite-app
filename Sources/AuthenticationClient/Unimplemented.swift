import XCTestDynamicOverlay

extension AuthenticationClient {
    public static let unimplemented = Self(
        login: XCTUnimplemented("\(Self.self).login"),
        restoreSession: XCTUnimplemented("\(Self.self).restoreSession"),
        logout: XCTUnimplemented("\(Self.self).logout")
    )
}
