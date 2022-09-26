import APIClient
import Buildkite
import ComposableArchitecture
import SwiftUI

struct AgentReducer: ReducerProtocol {
    struct State: Equatable {
        var agent: Buildkite.Agent
        var isStoppingAgent = false
    }

    enum Action: Equatable {
        case refresh
        case getAgentResponse(TaskResult<Buildkite.Agent>)
        case agentStatusTimer
        case stopAgent
        case stopAgentResponse(TaskResult<Bool>)
    }

    @Dependency(\.buildkite) var buildkite
    @Dependency(\.organization) var organization
    @Dependency(\.mainRunLoop) var mainRunLoop

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .refresh:
                return .none
            case .getAgentResponse(.success(let agent)):
                state.agent = agent
                return .none
            case .getAgentResponse(.failure(let error)):
                print(error)
                return .none
            case .agentStatusTimer:
                return .run { send in
                    for await _ in mainRunLoop.timer(interval: .seconds(3)) {
                        await send(.refresh)
                    }
                }
            case .stopAgent:
                state.isStoppingAgent = true
                let agentID = state.agent.id
                return .task {
                    await .stopAgentResponse(
                        TaskResult {
                            try await buildkite.stopAgent(
                                agentID,
                                organization(),
                                false
                            )
                            return true
                        }
                    )
                }
            case .stopAgentResponse(.success):
                state.isStoppingAgent = false
                return .none
            case .stopAgentResponse(.failure(let error)):
                print(error)
                state.isStoppingAgent = false
                return .none
            }
        }
    }
}

struct AgentView: View {
    let store: StoreOf<AgentReducer>

    var body: some View {
        WithViewStore(store) { viewStore in
            Form {
                Section {
                    HStack {
                        Text("State", bundle: .module)
                        Spacer()
                        ConnectionState(
                            state: viewStore.agent.connectionState,
                            isRunningJob: viewStore.agent.isRunningJob
                        )
                        Text(viewStore.agent.connectionState)
                    }
                    HStack {
                        Text("Version", bundle: .module)
                        Spacer()
                        Text(viewStore.agent.version)
                    }
                }
                Section(header: Text("HOST", bundle: .module)) {
                    HStack {
                        Text("Hostname", bundle: .module)
                        Spacer()
                        Text(viewStore.agent.hostname)
                    }
                    HStack {
                        Text("IP Address", bundle: .module)
                        Spacer()
                        Text(viewStore.agent.ipAddress)
                    }
                    HStack {
                        Text("User Agent", bundle: .module)
                        Spacer()
                        Text(viewStore.agent.userAgent)
                    }
                    HStack {
                        Text("Connected", bundle: .module)
                        Spacer()
                        Text(viewStore.agent.createdAt.formatted(.relative(presentation: .numeric, unitsStyle: .wide)))
                    }
                }
                Section(header: Text("TAGS", bundle: .module)) {
                    Text(viewStore.agent.metaData.joined())
                }
            }
            .onAppear {
                viewStore.send(.refresh)
                viewStore.send(.agentStatusTimer)
            }
            .navigationTitle(viewStore.agent.nameFormatted)
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button(
                        action: {
                            viewStore.send(.stopAgent)
                        },
                        label: {
                            Text("Stop", bundle: .module)
                        }
                    )
                    .disabled(
                        viewStore.isStoppingAgent || viewStore.agent.connectionState != "connected"
                    )
                }
            }
        }
    }
}

struct AgentView_Previews: PreviewProvider {
    static var previews: some View {
        AgentView(
            store: .init(
                initialState: .init(
                    agent: .init(
                        id: .init(),
                        graphqlId: "0",
                        url: .init(url: URL(string: "https://api.buildkite.com/v3/agents/0")!),
                        webURL: URL(string: "https://buildkite.com/agents/0")!,
                        name: "my-agent-1",
                        connectionState: "connected",
                        hostname: "my-agent-1.internal",
                        ipAddress: "0.0.0.1",
                        userAgent: "Mozilla",
                        version:
                            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/105.0.0.0 Safari/537.36",
                        createdAt: .now,
                        metaData: []
                    )
                ),
                reducer: AgentReducer()
            )
        )
    }
}
