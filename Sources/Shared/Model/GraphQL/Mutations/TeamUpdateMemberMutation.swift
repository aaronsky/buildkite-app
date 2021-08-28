//
//  TeamUpdateMemberMutation.swift
//  Shared
//
//  Created by Aaron Sky on 5/24/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation
import Buildkite

struct TeamUpdateMemberMutation: GraphQLQuery {
    static var query = """
mutation TeamMemberUpdate($input: TeamMemberUpdateInput!) {
  teamMemberUpdate(input: $input) {
    teamMember {
      id
      role
      user {
        id
        name
        email
      }
    }
  }
}
"""

    var id: String
    var role: Fragments.Team.Member.Role

    var variables: [String: JSONValue] {
        [
            "input": [
                "id": .string(id),
                "role": .string(role.rawValue)
            ]
        ]
    }

    init(id: String, role: Fragments.Team.Member.Role) {
        self.id = id
        self.role = role
    }

    struct Response: Decodable {
        var teamMemberUpdate: TeamMemberUpdate

        struct TeamMemberUpdate: Decodable {
            var teamMember: Fragments.Team.Member
        }
    }
}
