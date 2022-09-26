import APIClient
import ChangelogFeature
import ComposableArchitecture
import SwiftUI

public struct ProfileReducer: ReducerProtocol {
    public struct State: Equatable {
        var unreadChangelogsCount = 0
        @NavigationStateOf<Destinations> var path

        public init() {}
    }

    public enum Action: Equatable {
        case refresh
        case checkUnreadChangelogs
        case listChangelogsResponse(TaskResult<ChangelogFeature.ListQuery.Response>)
        case path(NavigationActionOf<Destinations>)
    }

    @Dependency(\.buildkite) var buildkite

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .refresh:
                return .run { send in
                    await send(.checkUnreadChangelogs)
                }
            case .checkUnreadChangelogs:
                return .task {
                    await .listChangelogsResponse(
                        TaskResult {
                            try await buildkite
                                .graphQLClient()
                                .sendQuery(
                                    ChangelogFeature.ListQuery(read: false)
                                )
                        }
                    )
                }
            case .listChangelogsResponse(.success(let response)):
                state.unreadChangelogsCount = response.viewer.changelogs.count
                return .none
            case .listChangelogsResponse(.failure(let error)):
                print(error)
                return .none
            case .path:
                return .none
            }
        }
        .navigationDestination(\.$path, action: /Action.path) {
            Destinations()
        }
    }

    public struct Destinations: ReducerProtocol {
        public enum State: Equatable, Hashable {
            case changelogs(ChangelogsListReducer.State)
        }

        public enum Action: Equatable {
            case changelogs(ChangelogsListReducer.Action)
        }

        public var body: some ReducerProtocol<State, Action> {
            Scope(
                state: /State.changelogs,
                action: /Action.changelogs
            ) {
                ChangelogsListReducer()
            }
        }
    }
}

public struct ProfileView: View {
    public let store: StoreOf<ProfileReducer>

    public init(
        store: StoreOf<ProfileReducer>
    ) {
        self.store = store
    }

    public var body: some View {
        NavigationStackStore(store.scope(state: \.$path, action: ProfileReducer.Action.path)) {
            WithViewStore(store, observe: \.unreadChangelogsCount) { unreadChangelogsCount in
                List {
                    NavigationLink(
                        state: ProfileReducer.Destinations.State.changelogs(.init())
                    ) {
                        HStack {
                            Text("Changelog", bundle: .module)
                            if unreadChangelogsCount.state > 0 {
                                Spacer()
                                    .frame(width: 5)
                                Text("\(unreadChangelogsCount.state)")
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(
                                        RoundedRectangle(cornerRadius: 3)
                                            .foregroundColor(Color(hue: 0, saturation: 0, brightness: 0.46))
                                    )
                            }
                        }
                    }
                }
                .listStyle(.inset)
                .navigationTitle(Text("Settings", bundle: .module))
                .navigationDestination(
                    store: store.scope(state: \.$path, action: ProfileReducer.Action.path)
                ) { store in
                    SwitchStore(store) {
                        CaseLet(
                            state: /ProfileReducer.Destinations.State.changelogs,
                            action: ProfileReducer.Destinations.Action.changelogs,
                            then: ChangelogsListView.init(store:)
                        )
                    }
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(
            store: .init(
                initialState: .init(),
                reducer: ProfileReducer()
            )
        )
    }
}
