import APIClient
import Buildkite
import ComposableArchitecture
import SwiftUI

public struct LoginReducer: ReducerProtocol {
    public enum State: Equatable {
        case restoreSession(RestoreSessionReducer.State)
        case createAccessToken(CreateAccessTokenReducer.State)
    }

    public enum Action: Equatable {
        case restoreSession(RestoreSessionReducer.Action)
        case createAccessToken(CreateAccessTokenReducer.Action)
        case authenticated
    }

    @Dependency(\.buildkite) var buildkite
    @Dependency(\.authentication) var authentication

    public init() {}
    
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .restoreSession(.authenticateResponse(.success(.authenticated))),
                    .createAccessToken(.authenticateResponse(.success(.authenticated))):
                return .task { .authenticated }
            case .restoreSession(.authenticateResponse(.success(.noSession))), .restoreSession(.authenticateResponse(.failure)):
                state = .createAccessToken(.init())
                return .none
            case .restoreSession, .createAccessToken:
                return .none
            case .authenticated:
                return .none
            }
        }
        .ifCaseLet(/State.restoreSession, action: /Action.restoreSession) {
            RestoreSessionReducer()
        }
        .ifCaseLet(/State.createAccessToken, action: /Action.createAccessToken) {
            CreateAccessTokenReducer()
        }
    }
}

public struct LoginView: View {
    let store: StoreOf<LoginReducer>

    public init(
        store: StoreOf<LoginReducer>
    ) {
        self.store = store
    }

    public var body: some View {
        SwitchStore(store) {
            CaseLet(state: /LoginReducer.State.restoreSession, action: LoginReducer.Action.restoreSession) { store in
                RestoreSessionView(store: store)
                    .navigationTitle("")
            }
            CaseLet(state: /LoginReducer.State.createAccessToken, action: LoginReducer.Action.createAccessToken) { store in
                CreateAccessTokenView(store: store)
                    .navigationTitle("Create Access Token")
            }
        }
    }
}
