//
//  TeamCreateMemberMutation.swift
//  Shared
//
//  Created by Aaron Sky on 5/24/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation
import Buildkite

struct TeamCreateMemberMutation: GraphQLQuery {
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
    
    var variables: [String: JSONValue] {
        [
            "input": [
                "teamID": .string(teamID),
                "userID": .string(userID),
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
