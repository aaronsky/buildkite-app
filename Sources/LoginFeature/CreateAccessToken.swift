import APIClient
import AuthenticationClient
import Buildkite
import ComposableArchitecture
import SwiftUI

public struct CreateAccessTokenReducer: ReducerProtocol {
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
        case authenticateResponse(TaskResult<AuthenticationClient.Status>)
    }

    @Dependency(\.buildkite) var buildkite
    @Dependency(\.authentication) var authentication

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
                    await .authenticateResponse(
                        TaskResult {
                            try await authentication.login(
                                .init(accessToken: token),
                                buildkite
                            )
                        }
                    )
                }
            case .authenticateResponse(.failure(let error)):
                state.errorMessage = error.localizedDescription
                state.isRequestInFlight = false
                return .none
            case .authenticateResponse:
                state.isRequestInFlight = false
                return .none
            }
        }
    }
}

public struct CreateAccessTokenView: View {
    @FocusState var focusedField: CreateAccessTokenReducer.State.Field?

    let store: StoreOf<CreateAccessTokenReducer>

    public init(
        store: StoreOf<CreateAccessTokenReducer>
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

                if let errorMessage = viewStore.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.callout)
                }
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
    func synchronize<Value: Equatable>(
        _ first: Binding<Value>,
        _ second: FocusState<Value>.Binding
    ) -> some View {
        self
            .onChange(of: first.wrappedValue) { second.wrappedValue = $0 }
            .onChange(of: second.wrappedValue) { first.wrappedValue = $0 }
    }
}
