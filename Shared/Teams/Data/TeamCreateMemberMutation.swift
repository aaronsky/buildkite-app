//
//  TeamCreateMemberMutation.swift
//  Shared
//
//  Created by Aaron Sky on 5/24/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation
import Buildkite

struct TeamCreateMemberMutation {
    static var query = """
mutation TeamCreateMember($input: TeamMemberCreateInput!) {
  teamMemberCreate(input: $input) {
    teamMemberEdge {
      node {
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
}
"""
    
    var teamID: String
    var userID: String
    
    var resource: GraphQL<Response> {
        GraphQL(rawQuery: TeamCreateMemberMutation.query, variables: [
            "input": [
                "teamID": .string(teamID),
                "userID": .string(userID),
            ]
        ])
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
