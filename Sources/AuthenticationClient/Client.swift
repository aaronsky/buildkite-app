import APIClient
import Buildkite
import Foundation

public struct AuthenticationClient {
    static let requiredScopes: Set<String> = [
        "read_agents",
        // "write_agents",
        "read_teams",
        "read_artifacts",
        // "write_artifacts",
        "read_builds",
        // "write_builds",
        "read_job_env",
        "read_build_logs",
        // "write_build_logs",
        "read_organizations",
        "read_pipelines",
        // "write_pipelines",
        "read_user",
        "graphql",
    ]

    public var login: @Sendable (Request, APIClient) async throws -> Status
    public var restoreSession: @Sendable (APIClient) async throws -> Status
    public var logout: @Sendable () async throws -> Void

    public init(
        login: @escaping @Sendable (Request, APIClient) async throws -> Status,
        restoreSession: @escaping @Sendable (APIClient) async throws -> Status,
        logout: @escaping @Sendable () async throws -> Void
    ) {
        self.login = login
        self.restoreSession = restoreSession
        self.logout = logout
    }

    public struct Request: Equatable, Sendable {
        public var accessToken: String
        public var storeInKeychainOnSuccess: Bool

        public init(
            accessToken: String,
            storeInKeychainOnSuccess: Bool = true
        ) {
            self.accessToken = accessToken
            self.storeInKeychainOnSuccess = storeInKeychainOnSuccess
        }
    }

    public enum Status: Equatable, Sendable {
        case noSession
        case authenticated
    }

    public enum Error: LocalizedError, Sendable {
        case badCredentials
        case tokenMissingScopes([String])
        case serviceUnavailable
        case unhandledBuildkiteError(BuildkiteError)
        case keychainError(Keychain.Error)

        init(
            _ error: BuildkiteError
        ) {
            switch error.statusCode {
            case .unauthorized:
                self = .badCredentials
            case .internalServerError, .serviceUnavailable:
                self = .serviceUnavailable
            default:
                self = .unhandledBuildkiteError(error)
            }
        }

        public var errorDescription: String? {
            switch self {
            case .badCredentials:
                return "Unknown user credentials"
            case .tokenMissingScopes(let scopes):
                return "Access token missing scopes: \(scopes.joined(separator: ", "))"
            case .serviceUnavailable:
                return "Buildkite is currently unavailable"
            case .unhandledBuildkiteError(let error):
                return "Unexpected Buildkite error – Code \(error.statusCode.rawValue)"
            case .keychainError:
                return nil
            }
        }
    }
}
