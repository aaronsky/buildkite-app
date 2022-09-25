import APIClient
import AuthenticationClient
import Buildkite
import ComposableArchitecture
import SwiftUI

public struct RestoreSessionReducer: ReducerProtocol {
    public struct State: Equatable {
        public init() {}
    }

    public enum Action: Equatable {
        case authenticate
        case authenticateResponse(TaskResult<AuthenticationClient.Status>)
    }

    @Dependency(\.buildkite) var buildkite
    @Dependency(\.authentication) var authentication

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .authenticate:
                return .task {
                    await .authenticateResponse(
                        TaskResult {
                            try await authentication.restoreSession(buildkite)
                        }
                    )
                }
            case .authenticateResponse:
                return .none
            }
        }
    }
}

public struct RestoreSessionView: View {
    let store: StoreOf<RestoreSessionReducer>

    public init(
        store: StoreOf<RestoreSessionReducer>
    ) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ProgressView()
                .onAppear { viewStore.send(.authenticate) }
        }
    }
}
