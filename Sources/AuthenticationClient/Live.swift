import APIClient
import Buildkite

extension AuthenticationClient {
    public static let live = Self(
        login: performLogin,
        restoreSession: { client in
            let attrs = try Keychain().credential(class: .internetPassword)
            guard let accessToken = String(data: attrs.data, encoding: .utf8) else { throw Keychain.Error.unexpectedCredentialData }
            return try await performLogin(
                request: .init(
                    accessToken: accessToken,
                    storeInKeychainOnSuccess: false
                ),
                client: client
            )
        },
        logout: {
            try Keychain().deleteAll()
        }
    )
}

@Sendable
private func performLogin(request: AuthenticationClient.Request, client: APIClient) async throws -> AuthenticationClient.Status {
    guard let tokenData = request.accessToken.data(using: .utf8) else { throw AuthenticationClient.Error.badCredentials }

    await client.setToken(request.accessToken)
    let tokenInfo = try await client.getAccessToken()
    let missingScopes = AuthenticationClient.requiredScopes.subtracting(Set(tokenInfo.scopes))

    guard missingScopes.isEmpty else {
        throw AuthenticationClient.Error.tokenMissingScopes(missingScopes.sorted())
    }

    if request.storeInKeychainOnSuccess {
        try Keychain().add(tokenData, for: tokenInfo.uuid.uuidString, class: .internetPassword)
    }

    return .authenticated
}

