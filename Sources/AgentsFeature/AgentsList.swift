import APIClient
import Buildkite
import ComposableArchitecture
import SwiftUI

public struct AgentsListReducer: ReducerProtocol {
    public struct State: Equatable {
        var agents: [Buildkite.Agent] = []
        var isLoading = false
        @BindableState var selectedAgent: Agent?

        public init() {}
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case refresh
        case listAgentsResponse(TaskResult<[Agent]>)
    }

    @Dependency(\.buildkite) var buildkite
    @Dependency(\.organization) var organization

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .refresh:
                state.isLoading = true
                return .task {
                    await .listAgentsResponse(
                        TaskResult {
                            try await buildkite
                                .listAgents(organization())
                        }
                    )
                }
            case .listAgentsResponse(.success(let agents)):
                state.isLoading = false
                state.agents = agents
                return .none
            case .listAgentsResponse(.failure(let error)):
                print(error)
                state.isLoading = false
                return .none
            }
        }
    }
}

public struct AgentsListView: View {
    public let store: StoreOf<AgentsListReducer>

    public init(
        store: StoreOf<AgentsListReducer>
    ) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            List(
                selection: viewStore.binding(\.$selectedAgent)
            ) {
                if viewStore.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else if viewStore.agents.isEmpty {
                    Text("No agents connected", bundle: .module)
                        .italic()
                } else {
                    ForEach(viewStore.agents) { agent in
                        HStack(alignment: .top) {
                            ConnectionState(
                                state: agent.connectionState,
                                isRunningJob: agent.isRunningJob
                            )
                            VStack(alignment: .leading) {
                                Text(agent.name)
                                    .font(.system(size: 15))
                                Text(agent.metaData.joined(separator: ","))
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(agent.version)
                                .font(.system(size: 14))
                        }
                    }
                }
            }
            .listStyle(.inset)
            .refreshable { await viewStore.send(.refresh, while: \.isLoading) }
            .onAppear { viewStore.send(.refresh) }
            .navigationTitle(Text("Agents", bundle: .module))
        }
    }
}

struct AgentsListView_Previews: PreviewProvider {
    static var previews: some View {
        AgentsListView(
            store: .init(
                initialState: .init(),
                reducer: AgentsListReducer()
            )
        )
    }
}
