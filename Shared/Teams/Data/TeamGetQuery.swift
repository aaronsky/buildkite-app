//
//  TeamGetQuery.swift
//  Shared
//
//  Created by Aaron Sky on 5/24/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation
import Buildkite

struct TeamGetQuery {
    static var query = """
query TeamGet($slug: ID!, $first: Int!) {
  team(slug: $slug) {
    id
    name
    slug
    description
    privacy
    members(first: $first) {
      edges{
        node{
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
}
"""
    
    var slug: String
    
    var resource: GraphQL<Response> {
        GraphQL(rawQuery: TeamGetQuery.query, variables: [
            "slug": .string(slug),
            "first": 100,
        ])
    }
    
    init(organization: String, team: String) {
        self.slug = "\(organization)/\(team)"
    }
    
    struct Response: Decodable {
        var team: Fragments.Team
    }
}
