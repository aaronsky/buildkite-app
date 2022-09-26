import APIClient
import ComposableArchitecture
import GraphQLHelpers
import SwiftUI

public struct UsersListReducer: ReducerProtocol {
    public struct State: Hashable {
        var teamSlug: String?
        var isLoading = false
        var users: Connection<ListQuery.Response.Organization.Member> = []
        @BindableState var search = ""
        @BindableState public internal(set) var selectedUser: ListQuery.Response.Organization.Member?

        public init(
            teamSlug: String? = nil
        ) {
            self.teamSlug = teamSlug
        }
    }

    public enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case refresh
        case listUsersResponse(TaskResult<ListQuery.Response>)
    }

    @Dependency(\.buildkite) var buildkite
    @Dependency(\.organization) var organization

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.$search):
                print(state.search)
                return .none
            case .binding(\.$selectedUser):
                print(state.search)
                return .none
            case .binding:
                return .none
            case .refresh:
                state.isLoading = true
                let (search, teamSlug) = (state.search, state.teamSlug)
                return .task {
                    await .listUsersResponse(
                        TaskResult {
                            try await buildkite
                                .graphQLClient()
                                .sendQuery(
                                    ListQuery(
                                        organization: organization(),
                                        usersMatching: search,
                                        teamsMatching: teamSlug
                                    )
                                )
                        }
                    )
                }
            case .listUsersResponse(.success(let response)):
                state.isLoading = false
                state.users = response.organization.members
                return .none
            case .listUsersResponse(.failure(let error)):
                print(error)
                state.isLoading = false
                return .none
            }
        }
    }
}

public struct UsersListView: View {
    public let store: StoreOf<UsersListReducer>

    public init(
        store: StoreOf<UsersListReducer>
    ) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            List(
                viewStore.users,
                selection: viewStore.binding(\.$selectedUser)
            ) { user in
                HStack {
                    AsyncImage(
                        url: user.user.avatar.url,
                        content: { image in
                            image.resizable()
                        },
                        placeholder: {
                            ProgressView()
                        }
                    )
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())

                    VStack(alignment: .leading) {
                        Text(user.user.name)
                        Text(user.user.email)
                            .font(.caption)
                    }
                }
            }
            .listStyle(.inset)
            .searchable(text: viewStore.binding(\.$search))
            .refreshable { await viewStore.send(.refresh, while: \.isLoading) }
            .onAppear { viewStore.send(.refresh) }
            .navigationTitle(Text("Users", bundle: .module))
        }
    }
}

struct UsersListView_Previews: PreviewProvider {
    static var previews: some View {
        UsersListView(
            store: .init(
                initialState: .init(),
                reducer: UsersListReducer()
            )
        )
    }
}
