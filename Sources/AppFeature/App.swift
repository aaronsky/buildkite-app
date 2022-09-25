import APIClient
import ComposableArchitecture
import LoginFeature
import SwiftUI

public struct AppReducer: ReducerProtocol {
    public enum State: Equatable {
        case login(LoginReducer.State)
        case home(HomeReducer.State)

        public init() {
            self = .login(.restoreSession(.init()))
        }
    }

    public enum Action: Equatable {
        case login(LoginReducer.Action)
        case home(HomeReducer.Action)
    }

    @Dependency(\.buildkite) var buildkite

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .login(.authenticated):
                state = .home(.init())
                return .none
            case .login:
                return .none
            case .home:
                return .none
            }
        }
        .ifCaseLet(/State.login, action: /Action.login) {
            LoginReducer()
        }
        .ifCaseLet(/State.home, action: /Action.home) {
            HomeReducer()
        }
    }
}

public struct AppView: View {
    let store: StoreOf<AppReducer>

    public init(
        store: StoreOf<AppReducer>
    ) {
        self.store = store
    }

    public var body: some View {
        SwitchStore(store) {
            CaseLet(state: /AppReducer.State.login, action: AppReducer.Action.login) { store in
                NavigationStack {
                    LoginView(store: store)
                }
            }
            CaseLet(state: /AppReducer.State.home, action: AppReducer.Action.home) { store in
                HomeView(store: store)
            }
        }
    }
}
