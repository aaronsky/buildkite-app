import APIClient
import Buildkite
import ComposableArchitecture
import SwiftUI

public struct BuildReducer: ReducerProtocol {
    public struct State: Hashable {
        let pipelineSlug: String
        let buildNumber: Int

        var build: Build?
        var isLoading = false
        var errorMessage: String?

        public init(
            pipelineSlug: String,
            buildNumber: Int
        ) {
            self.pipelineSlug = pipelineSlug
            self.buildNumber = buildNumber
        }
    }

    public enum Action: Equatable {
        case refresh
        case getBuildResponse(TaskResult<Build>)
    }

    @Dependency(\.buildkite) var buildkite
    @Dependency(\.organization) var organization

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .refresh:
                let pipelineSlug = state.pipelineSlug
                let buildNumber = state.buildNumber
                state.isLoading = true
                return .task {
                    await .getBuildResponse(
                        TaskResult {
                            try await buildkite
                                .getBuild(
                                    buildNumber,
                                    organization(),
                                    pipelineSlug
                                )
                        }
                    )
                }
            case .getBuildResponse(.success(let build)):
                state.isLoading = false
                state.build = build
                return .none
            case .getBuildResponse(.failure(let error)):
                print(error)
                state.isLoading = false
                state.errorMessage = "\(organization())/\(state.pipelineSlug) #\(state.buildNumber) could not be loaded"
                return .none
            }
        }
    }
}

public struct BuildView: View {
    let store: StoreOf<BuildReducer>

    public init(
        store: StoreOf<BuildReducer>
    ) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                if viewStore.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else if let build = viewStore.build {
                    LazyVStack {
                        ForEach(build.jobs) { job in
                            JobView(job: job)
                        }
                    }
                } else if let errorMessage = viewStore.errorMessage {
                    Text(errorMessage)
                        .italic()
                } else {
                    Text("Something went wrong!")
                        .italic()
                }
            }
            .refreshable { await viewStore.send(.refresh, while: \.isLoading) }
            .onAppear { viewStore.send(.refresh) }
        }
    }
}
