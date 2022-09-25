import APIClient
import BuildsFeature
import ComposableArchitecture
import Formatters
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
                    Text("No builds found")
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
                                        .font(.caption)
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

    private func caption(for build: ListQuery.Response.Build) -> Text {
        var chunks: [Text] = []
        if let createdByName = build.createdBy?.name {
            chunks.append(Text(createdByName))
        }
        chunks.append(Text("Build #\(build.number)"))
        chunks.append(Text(build.commit.prefix(7)))
        if let createdAt = build.createdAt {
            chunks.append(
                Text(
                    "\(createdAt, formatter: friendlyRelativeDateFormatter)"
                )
            )
        }

        return chunks.joined(separator: " — ")
    }
}

extension Array where Element == Text {
    func joined(separator: Text) -> Text {
        var result = Text("")
        var iter = makeIterator()
        if let first = iter.next() {
            result = result + first
            while let next = iter.next() {
                result = result + separator
                result = result + next
            }
        }
        return result
    }

    func joined<S: StringProtocol>(separator: S) -> Text {
        joined(separator: Text(separator))
    }
}
