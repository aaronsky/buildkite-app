import APIClient
import Buildkite
import ComposableArchitecture
import SwiftUI

struct TeamsListReducer: ReducerProtocol {
    struct State: Equatable, Sendable {
        var isLoading = false
        var teams: [Buildkite.Team] = []
    }

    enum Action: Equatable {
        case refresh
        case listTeamsResponse(TaskResult<[Buildkite.Team]>)
    }

    @Dependency(\.buildkite) var buildkite
    @Dependency(\.organization) var organization

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .refresh:
                state.isLoading = true
                return .task {
                    await .listTeamsResponse(
                        TaskResult {
                            try await buildkite.listTeams(organization())
                        }
                    )
                }
            case .listTeamsResponse(.success(let teams)):
                state.isLoading = false
                state.teams = teams
                return .none
            case .listTeamsResponse(.failure(let error)):
                print(error)
                state.isLoading = false
                return .none
            }
        }
    }
}

struct TeamsListView: View {
    let store: StoreOf<TeamsListReducer>

    var body: some View {
        WithViewStore(store) { viewStore in
            List(viewStore.teams) { team in
                Text(team.name)  // emojis
            }
            .listStyle(.inset)
            .refreshable { await viewStore.send(.refresh, while: \.isLoading) }
            .onAppear { viewStore.send(.refresh) }
            .navigationTitle(Text("Teams", bundle: .module))
        }
    }
}

struct TeamsListView_Previews: PreviewProvider {
    static var previews: some View {
        TeamsListView(
            store: .init(
                initialState: .init(),
                reducer: TeamsListReducer()
            )
        )
    }
}
