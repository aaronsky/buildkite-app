import ComposableArchitecture
import GraphQLHelpers
import SwiftUI
import UsersFeature

struct TeamReducer: ReducerProtocol {
    struct State: Hashable {
        var team: Fragments.Team
        @NavigationStateOf<UserReducer> var member
        @PresentationStateOf<UsersListReducer> var usersList
    }

    enum Action: Equatable {
        case refresh
        case getTeamResponse(TaskResult<Fragments.Team>)
        case addMember(userID: String)
        case deleteMembers(offsets: IndexSet)
        case deletedMemberResponse(DeleteMemberMutation.Response)
        case member(NavigationActionOf<UserReducer>)
        case usersList(PresentationActionOf<UsersListReducer>)
    }

    @Dependency(\.buildkite) var buildkite
    @Dependency(\.organization) var organization

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .refresh:
                let teamSlug = state.team.slug
                return .task {
                    await .getTeamResponse(
                        TaskResult {
                            try await buildkite
                                .graphQLClient()
                                .sendQuery(GetQuery(slug: teamSlug))
                                .team
                        }
                    )
                }
            case .getTeamResponse(.success(let team)):
                state.team = team
                return .none
            case .getTeamResponse(.failure(let error)):
                print(error)
                return .none
            case .addMember(let userID):
                let teamID = state.team.id
                return .task {
                    _ =
                        try await buildkite
                        .graphQLClient()
                        .sendQuery(
                            CreateMemberMutation(
                                teamID: teamID,
                                userID: userID
                            )
                        )
                    return .refresh
                }
            case .deleteMembers(let offsets):
                let ids = offsets.compactMap { state.team.members[$0].id }
                return .run { send in
                    try await withThrowingTaskGroup(of: DeleteMemberMutation.Response.self) { group in
                        for id in ids {
                            group.addTask {
                                try await buildkite
                                    .graphQLClient()
                                    .sendQuery(DeleteMemberMutation(id: id))
                            }
                        }
                        for try await deletedMember in group {
                            await send(.deletedMemberResponse(deletedMember))
                        }
                    }
                }
            case .deletedMemberResponse(let deletedMember):
                state.team.members.removeAll(where: {
                    $0.id == deletedMember.teamMemberDelete.deletedTeamMemberID
                })
                return .none
            case .member:
                return .none
            case .usersList(.dismiss):
                guard let userID = state.usersList?.selectedUser?.user.id else { return .none }
                return .task { .addMember(userID: userID) }
            case .usersList:
                return .none
            }
        }
        .navigationDestination(\.$member, action: /Action.member) {
            UserReducer()
        }
        .presentationDestination(\.$usersList, action: /Action.usersList) {
            UsersListReducer()
        }
    }
}

struct TeamView: View {
    let store: StoreOf<TeamReducer>

    var body: some View {
        WithViewStore(store) { viewStore in
            Form {
                Section {
                    Text(viewStore.team.privacy.rawValue)
                    if let description = viewStore.team.description {
                        Text(description)  // emojis
                    }
                }
                Section(header: Text("MEMBERS", bundle: .module)) {
                    ForEach(viewStore.team.members) { member in
                        NavigationLink(member.user.name, state: UserReducer.State(memberID: member.uuid))
                    }
                    .onDelete { offsets in
                        viewStore.send(.deleteMembers(offsets: offsets))
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        viewStore.send(.usersList(.present(.init(teamSlug: viewStore.team.slug))))
                    } label: {
                        Label {
                            Text("Add Member", bundle: .module)
                        } icon: {
                            Image(systemName: "person.badge.plus")
                        }
                        .labelStyle(.iconOnly)
                    }
                }
            }
            .sheet(
                store: store.scope(
                    state: \.$usersList,
                    action: TeamReducer.Action.usersList
                ),
                content: UsersListView.init(store:)
            )
            .navigationDestination(
                store: store.scope(state: \.$member, action: TeamReducer.Action.member),
                destination: UserView.init(store:)
            )
        }
    }
}

struct TeamView_Previews: PreviewProvider {
    static var previews: some View {
        TeamView(
            store: .init(
                initialState: .init(
                    team: .init(
                        id: "0",
                        name: "My Team",
                        slug: "my-team",
                        privacy: .visible,
                        members: []
                    )
                ),
                reducer: TeamReducer()
            )
        )
    }
}
