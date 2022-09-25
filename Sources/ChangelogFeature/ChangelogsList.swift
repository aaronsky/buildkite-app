import APIClient
import ComposableArchitecture
import GraphQLHelpers
import SwiftUI

public struct ChangelogsListReducer: ReducerProtocol {
    public struct State: Hashable {
        var isLoading = false
        var changelogs: Connection<ListQuery.Response.Changelog> = []

        public init() {}
    }

    public enum Action: Equatable {
        case refresh
        case listChangelogsResponse(TaskResult<ListQuery.Response>)
    }

    @Dependency(\.buildkite) var buildkite

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .refresh:
                state.isLoading = true
                return .task {
                    await .listChangelogsResponse(
                        TaskResult {
                            try await buildkite
                                .graphQLClient()
                                .sendQuery(ListQuery())
                        }
                    )
                }
            case .listChangelogsResponse(.success(let response)):
                state.isLoading = false
                state.changelogs = response.viewer.changelogs
                return .none
            case .listChangelogsResponse(.failure(let error)):
                print(error)
                state.isLoading = false
                return .none
            }
        }
    }
}

public struct ChangelogsListView: View {
    public let store: StoreOf<ChangelogsListReducer>

    public init(
        store: StoreOf<ChangelogsListReducer>
    ) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            List(viewStore.changelogs) { changelog in
                NavigationLink {
                    ChangelogView(changelog: changelog)
                } label: {
                    HStack {
                        Text(changelog.publishedAt.formatted(.dateTime.month().day()))
                            .font(.footnote)
                        Text(changelog.title)
                        Spacer()
                        Text(changelog.tag)
                    }
                }
            }
            .listStyle(.inset)
            .refreshable { await viewStore.send(.refresh, while: \.isLoading) }
            .onAppear { viewStore.send(.refresh) }
            .navigationTitle("Changelogs")
        }
    }
}
