import APIClient
import BuildsFeature
import ComposableArchitecture
import SwiftUI

public struct PipelineReducer: ReducerProtocol {
    public struct State: Hashable {
        var pipeline: ListQuery.Response.Pipeline
        @NavigationStateOf<BuildReducer> var build
    }

    public enum Action: Equatable {
        case build(NavigationActionOf<BuildReducer>)
    }

    @Dependency(\.buildkite) var buildkite

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            return .none
        }
        .navigationDestination(\.$build, action: /Action.build) {
            BuildReducer()
        }
    }
}

public struct PipelineView: View {
    let store: StoreOf<PipelineReducer>

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                HStack {
                    Text(viewStore.pipeline.name)  // emojis
                    switch viewStore.pipeline.visibility {
                    case .public:
                        Image(systemName: "eye")
                    case .private:
                        Image(systemName: "lock.fill")
                    }
                }
            }
            List {
                let builds = viewStore.pipeline.builds
                if builds.isEmpty {
                    Text("No builds found", bundle: .module)
                        .italic()
                } else {
                    ForEach(builds) { build in
                        NavigationLink(
                            state: BuildReducer.State(
                                pipelineSlug: viewStore.pipeline.slug,
                                buildNumber: build.number
                            )
                        ) {
                            HStack {
                                BuildState(state: build.state.rawValue)
                                VStack(alignment: .leading) {
                                    Text(build.message ?? "")  // emojis
                                        .font(.body)
                                    caption(for: build)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.inset)
            .navigationDestination(
                store: store.scope(state: \.$build, action: PipelineReducer.Action.build),
                destination: BuildView.init(store:)
            )
        }
    }

    @ViewBuilder
    private func caption(for build: ListQuery.Response.Build) -> some View {
        HStack {
            if let createdByName = build.createdBy?.name {
                Text(createdByName)
                    .font(.caption)
                Text(" – ")
                    .font(.caption)
            }
            Text("Build #\(build.number)", bundle: .module)
                .font(.caption)
            Text(" – ")
                .font(.caption)
            Text(build.commit.prefix(7))
                .font(.caption)
            if let createdAt = build.createdAt {
                Text(" – ")
                    .font(.caption)
                Text(createdAt.formatted(.relative(presentation: .numeric, unitsStyle: .wide)))
                    .font(.caption)
            }
        }
    }
}

struct PipelineView_Previews: PreviewProvider {
    static var previews: some View {
        PipelineView(
            store: .init(
                initialState: .init(
                    pipeline: .init(
                        id: "0",
                        uuid: .init(),
                        name: "My Pipeline",
                        url: URL(string: "https://buildkite.com/my-org/my-pipeline")!,
                        slug: "my-pipeline",
                        visibility: .public,
                        builds: []
                    )
                ),
                reducer: PipelineReducer()
            )
        )
    }
}
