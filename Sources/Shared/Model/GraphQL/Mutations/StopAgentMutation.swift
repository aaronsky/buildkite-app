//
//  StopAgentMutation.swift
//  Buildkite
//
//  Created by Aaron Sky on 7/6/20.
//

import Foundation
import Buildkite

struct StopAgentMutation: GraphQLQuery {
    static var query = """
mutation AgentStop($input: AgentStopInput!) {
  agentStop(input: $input) {
    agent {
      ...agent
    }
  }
}
"""

    var teamID: String
    var userID: String

    var variables: [String: JSONValue] {
        [
            "input": [
                "teamID": .string(teamID),
                "userID": .string(userID)
            ]
        ]
    }

    init(teamID: String, userID: String) {
        self.teamID = teamID
        self.userID = userID
    }

    struct Response: Decodable {
        var teamMemberCreate: TeamMemberCreate

        struct TeamMemberCreate: Decodable {
            var teamMemberEdge: Connection<Fragments.Team.Member>.Edge
        }
    }
}
