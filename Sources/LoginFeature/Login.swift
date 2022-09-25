import APIClient
import Buildkite
import ComposableArchitecture
import SwiftUI

public struct LoginReducer: ReducerProtocol {
    public struct State: Equatable {
        enum Field: String, Hashable {
            case accessToken
        }

        @BindableState var accessToken = ""
        @BindableState var focusedField: Field? = nil
        @BindableState var showAccessTokenField = false

        var canLogIn = false
        var isRequestInFlight = false
        var errorMessage: String?

        public init() {}
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case loginButtonTapped
        case validateTokenResponse(TaskResult<ValidateTokenResponse>)
    }

    @Dependency(\.buildkite) var buildkite

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.$accessToken):
                state.canLogIn = !state.accessToken.isEmpty
                return .none
            case .binding:
                return .none
            case .loginButtonTapped:
                state.errorMessage = nil
                state.isRequestInFlight = true
                let token = state.accessToken
                return .task {
                    await .validateTokenResponse(
                        TaskResult {
                            await buildkite.setToken(token)
                            let accessToken = try await buildkite.getAccessToken()
                            return ValidateTokenResponse(accessToken: accessToken)
                        }
                    )
                }
            case .validateTokenResponse(.success(let response)) where !response.isValid:
                state.errorMessage = response.errorMessage
                state.isRequestInFlight = false
                return .none
            case .validateTokenResponse(.failure(let error)):
                state.errorMessage = error.localizedDescription
                state.isRequestInFlight = false
                return .none
            case .validateTokenResponse:
                state.isRequestInFlight = false
                return .none
            }
        }
    }
}

public struct ValidateTokenResponse: Equatable {
    private static let requiredScopes: Set<String> = [
        "read_agents",
        //        "write_agents",
        "read_teams",
        "read_artifacts",
        //        "write_artifacts",
        "read_builds",
        //        "write_builds",
        "read_job_env",
        "read_build_logs",
        //        "write_build_logs",
        "read_organizations",
        "read_pipelines",
        //        "write_pipelines",
        "read_user",
        "graphql",
    ]

    public private(set) var accessToken: AccessToken
    public private(set) var isValid: Bool
    public private(set) var errorMessage: String?

    init(
        accessToken: AccessToken
    ) {
        self.accessToken = accessToken

        let missingScopes = Self.requiredScopes.subtracting(Set(accessToken.scopes)).sorted()
        isValid = missingScopes.isEmpty

        if !isValid {
            errorMessage = "Token is missing scopes: \(missingScopes.joined(separator: ","))"
        }
    }
}

public struct LoginView: View {
    @FocusState var focusedField: LoginReducer.State.Field?

    let store: StoreOf<LoginReducer>

    public init(
        store: StoreOf<LoginReducer>
    ) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 16) {
                Text(
                    """
                    This app requires elevated access in order to offer the same functionality as the Buildkite
                    website. It will never use this access to modify your organization without consent, nor will
                    it be used for tracking.

                    Please create a token and copy it into the text field below.
                    """
                )
                HStack {
                    if viewStore.showAccessTokenField {
                        TextField(
                            "Access Token",
                            text: viewStore.binding(\.$accessToken)
                        )
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .accessToken)
                    } else {
                        SecureField(
                            "Access Token",
                            text: viewStore.binding(\.$accessToken)
                        )
                        .textFieldStyle(.roundedBorder)
                        .focused($focusedField, equals: .accessToken)
                    }
                    Toggle(
                        isOn: viewStore.binding(\.$showAccessTokenField)
                    ) {
                        Label("Show Access Token", systemImage: "eye")
                            .labelStyle(.iconOnly)
                    }
                    .toggleStyle(.button)
                }

                if let errorMessage = viewStore.errorMessage {
                    Text(errorMessage)
                }

                Button(
                    action: {
                        viewStore.send(.loginButtonTapped)
                    },
                    label: {
                        Text("Log In")

                        if viewStore.isRequestInFlight {
                            ProgressView()
                        }
                    }
                )
                .disabled(!viewStore.canLogIn)
            }
            .padding(.horizontal)
            .disabled(viewStore.isRequestInFlight)
            .synchronize(
                viewStore.binding(\.$focusedField),
                self.$focusedField
            )
        }
    }
}

extension View {
    public func synchronize<Value: Equatable>(
        _ first: Binding<Value>,
        _ second: FocusState<Value>.Binding
    ) -> some View {
        self
            .onChange(of: first.wrappedValue) { second.wrappedValue = $0 }
            .onChange(of: second.wrappedValue) { first.wrappedValue = $0 }
    }
}
