import APIClient
import ComposableArchitecture
import GraphQLHelpers
import SwiftUI

public struct UserReducer: ReducerProtocol {
    public struct State: Hashable {
        var memberID: String
        var user: Fragments.User?

        public init(
            memberID: String
        ) {
            self.memberID = memberID
        }
    }

    public enum Action: Equatable {
        case refresh
        case getUserResponse(TaskResult<GetQuery.Response>)
    }

    @Dependency(\.buildkite) var buildkite
    @Dependency(\.organization) var organization

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .refresh:
                let memberID = state.memberID
                return .task {
                    await .getUserResponse(
                        TaskResult {
                            try await buildkite
                                .graphQLClient()
                                .sendQuery(
                                    GetQuery(
                                        organization: organization(),
                                        memberID: memberID
                                    )
                                )
                        }
                    )
                }
            case .getUserResponse(.success(let response)):
                state.user = response.organizationMember?.user
                return .none
            case .getUserResponse(.failure(let error)):
                print(error)
                return .none
            }
        }
    }
}

public struct UserView: View {
    public let store: StoreOf<UserReducer>

    public init(
        store: StoreOf<UserReducer>
    ) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            Text("Hello, \(viewStore.memberID)")
        }
    }
}
