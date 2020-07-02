//
//  TeamDeleteMemberMutation.swift
//  Shared
//
//  Created by Aaron Sky on 5/24/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation
import Buildkite

struct TeamDeleteMemberMutation: GraphQLQuery {
    static var query = """
mutation TeamMemberDelete($input: TeamMemberDeleteInput!) {
  teamMemberDelete(input: $input) {
    deletedTeamMemberID
  }
}
"""
    
    var id: String
    
    var variables: [String : JSONValue] {
        [
            "input": [
                "id": .string(id),
            ]
        ]
    }
    
    
    init(id: String) {
        self.id = id
    }
    
    struct Response: Decodable {
        var teamMemberDelete: TeamMemberDelete
        
        struct TeamMemberDelete: Decodable {
            var deletedTeamMemberID: String
        }
    }
}

