import APIClient
import AgentsFeature
import ComposableArchitecture
import PipelinesFeature
import ProfileFeature
import SwiftUI
import UsersFeature

public struct HomeReducer: ReducerProtocol {
    public struct State: Equatable {
        var pipelines: PipelinesListReducer.State = .init()
        var agents: AgentsListReducer.State = .init()
        var users: UsersListReducer.State = .init()
        var profile: ProfileReducer.State = .init()
    }

    public enum Action: Equatable {
        case pipelines(PipelinesListReducer.Action)
        case agents(AgentsListReducer.Action)
        case users(UsersListReducer.Action)
        case profile(ProfileReducer.Action)
    }

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.pipelines, action: /Action.pipelines) {
            PipelinesListReducer()
        }
        Scope(state: \.agents, action: /Action.agents) {
            AgentsListReducer()
        }
        Scope(state: \.users, action: /Action.users) {
            UsersListReducer()
        }
        Scope(state: \.profile, action: /Action.profile) {
            ProfileReducer()
        }
    }
}

public struct HomeView: View {
    let store: StoreOf<HomeReducer>

    public init(
        store: StoreOf<HomeReducer>
    ) {
        self.store = store
    }

    public var body: some View {
        TabView {
            NavigationStack {
                PipelinesListView(
                    store: store.scope(
                        state: \.pipelines,
                        action: HomeReducer.Action.pipelines
                    )
                )
            }
            .tabItem {
                Label("Pipelines", systemImage: "hammer.fill")
                    .accessibility(label: Text("Pipelines"))
            }

            NavigationStack {
                AgentsListView(
                    store: store.scope(
                        state: \.agents,
                        action: HomeReducer.Action.agents
                    )
                )
            }
            .tabItem {
                Label("Agents", systemImage: "ant.fill")
                    .accessibility(label: Text("Agents"))
            }

            NavigationStack {
                UsersListView(
                    store: store.scope(
                        state: \.users,
                        action: HomeReducer.Action.users
                    )
                )
            }
            .tabItem {
                Label("Users", systemImage: "person.3.fill")
                    .accessibility(label: Text("Users"))
            }

            NavigationStack {
                ProfileView(
                    store: store.scope(
                        state: \.profile,
                        action: HomeReducer.Action.profile
                    )
                )
            }
            .tabItem {
                Label("More", systemImage: "ellipsis")
                    .accessibility(label: Text("More"))
            }
        }
    }
}
