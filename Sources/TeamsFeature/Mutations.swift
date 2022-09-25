import Buildkite
import Foundation
import GraphQLHelpers

public struct CreateMemberMutation: Query {
    public struct Response: Decodable, Equatable {
        public var teamMemberCreate: TeamMemberCreate

        public struct TeamMemberCreate: Decodable, Equatable {
            public var teamMemberEdge: Edge

            public struct Edge: Decodable, Equatable {
                var node: Fragments.Team.Member
                var cursor: String?
            }
        }
    }

    public static let query: String = """
        mutation TeamCreateMember($input: TeamMemberCreateInput!) {
          teamMemberCreate(input: $input) {
            teamMemberEdge {
              node {
                id
                uuid
                role
                user {
                  id
                  uuid
                  name
                  email
                  avatar {
                    url
                  }
                  bot
                  hasPassword
                }
              }
            }
          }
        }
        """

    var teamID: String
    var userID: String

    public var variables: [String: JSONValue] {
        [
            "input": [
                "teamID": .string(teamID),
                "userID": .string(userID),
            ]
        ]
    }

    init(
        teamID: String,
        userID: String
    ) {
        self.teamID = teamID
        self.userID = userID
    }
}

public struct DeleteMemberMutation: Query {
    public struct Response: Decodable, Equatable {
        public var teamMemberDelete: TeamMemberDelete

        public struct TeamMemberDelete: Decodable, Equatable {
            public var deletedTeamMemberID: String
        }
    }

    public static let query: String = """
        mutation TeamMemberDelete($input: TeamMemberDeleteInput!) {
          teamMemberDelete(input: $input) {
            deletedTeamMemberID
          }
        }
        """

    var id: String

    public var variables: [String: JSONValue] {
        [
            "input": [
                "id": .string(id)
            ]
        ]
    }

    init(
        id: String
    ) {
        self.id = id
    }
}
