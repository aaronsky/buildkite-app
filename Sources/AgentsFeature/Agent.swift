import APIClient
import Buildkite
import ComposableArchitecture
import Formatters
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
                        Text("State")
                        Spacer()
                        ConnectionState(
                            state: viewStore.agent.connectionState,
                            isRunningJob: viewStore.agent.isRunningJob
                        )
                        Text(viewStore.agent.connectionState)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(viewStore.agent.version)
                    }
                }
                Section(header: Text("HOST")) {
                    HStack {
                        Text("Hostname")
                        Spacer()
                        Text(viewStore.agent.hostname)
                    }
                    HStack {
                        Text("IP Address")
                        Spacer()
                        Text(viewStore.agent.ipAddress)
                    }
                    HStack {
                        Text("User Agent")
                        Spacer()
                        Text(viewStore.agent.userAgent)
                    }
                    HStack {
                        Text("Connected")
                        Spacer()
                        Text("\(viewStore.agent.createdAt, formatter: friendlyRelativeDateFormatter)")
                    }
                }
                Section(header: Text("TAGS")) {
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
                            Text("Stop")
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
