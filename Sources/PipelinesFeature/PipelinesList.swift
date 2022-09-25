import APIClient
import BuildsFeature
import Charts
import ComposableArchitecture
import GraphQLHelpers
import SwiftUI

public struct PipelinesListReducer: ReducerProtocol {
    public struct State: Hashable {
        var pipelines: Connection<ListQuery.Response.Pipeline> = []
        var isLoading = false
        @BindableState var search = ""
        @NavigationStateOf<PipelineReducer> var pipeline

        public init() {}
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case refresh
        case listPipelinesResponse(TaskResult<ListQuery.Response>)
        case pipeline(NavigationActionOf<PipelineReducer>)
    }

    @Dependency(\.buildkite) var buildkite
    @Dependency(\.organization) var organization

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.$search):
                return .task { .refresh }
            case .binding:
                return .none
            case .refresh:
                state.isLoading = true
                let search = state.search
                return .task {
                    await .listPipelinesResponse(
                        TaskResult {
                            try await buildkite
                                .graphQLClient()
                                .sendQuery(
                                    ListQuery(
                                        organization: organization(),
                                        pipelinesSearch: search
                                    )
                                )
                        }
                    )
                }
            case .listPipelinesResponse(.success(let response)):
                state.isLoading = false
                state.pipelines = response.organization.pipelines
                return .none
            case .listPipelinesResponse(.failure(let error)):
                print(error)
                state.isLoading = false
                return .none
            case .pipeline:
                return .none
            }
        }
        .navigationDestination(\.$pipeline, action: /Action.pipeline) {
            PipelineReducer()
        }
    }
}

public struct PipelinesListView: View {
    public let store: StoreOf<PipelinesListReducer>

    public init(
        store: StoreOf<PipelinesListReducer>
    ) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            List {
                if viewStore.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else if viewStore.pipelines.isEmpty {
                    Text("No pipelines found")
                        .italic()
                } else {
                    ForEach(viewStore.pipelines) { pipeline in
                        NavigationLink(
                            state: PipelineReducer.State(pipeline: pipeline)
                        ) {
                            VStack(alignment: .leading) {
                                HStack {
                                    BuildState(
                                        state: (pipeline.builds
                                            .first?
                                            .state ?? .notRun)
                                            .rawValue
                                    )
                                    Text(pipeline.name)
                                }
                                Chart {
                                    ForEach(
                                        pipeline.builds
                                            .prefix(30)
                                            .reversed()
                                    ) { build in
                                        if let createdAt = build.createdAt, let finishedAt = build.finishedAt {
                                            BarMark(
                                                x: .value("\(build.number)", build.number),
                                                y: .value("Build Duration", finishedAt.timeIntervalSince(createdAt)),
                                                width: 5
                                            )
                                        }
                                    }
                                }
                            }
                            .frame(height: 80)
                        }
                    }
                }
            }
            .searchable(text: viewStore.binding(\.$search))
            .listStyle(.inset)
            .refreshable { await viewStore.send(.refresh, while: \.isLoading) }
            .onAppear { viewStore.send(.refresh) }
            .navigationTitle("Pipelines")
            .navigationDestination(
                store: store.scope(state: \.$pipeline, action: PipelinesListReducer.Action.pipeline),
                destination: PipelineView.init(store:)
            )
        }
    }
}
