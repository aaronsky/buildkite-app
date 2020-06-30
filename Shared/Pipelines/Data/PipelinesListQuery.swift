//
//  PipelinesListQuery.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/27/20.
//

import Foundation

import Foundation
import Buildkite

struct PipelinesListQuery {
    static var query = """
query PipelinesList($organization: ID!, $limit: Int!, $cursor: String, $search: String, $team: TeamSelector, $favorite: Boolean) {
  organization(slug: $organization) {
    pipelines(first: $limit, after: $cursor, search: $search, team: $team, favorite: $favorite) {
      edges {
        node {
          id
          name
          defaultBranch
          metrics {
            edges {
              node {
                id
                label
                value
              }
            }
          }
          builds(first: 10) {
            edges {
              node {
                id
                uuid
                number
                url
                state
                startedAt
                finishedAt
              }
            }
          }
        }
        cursor
      }
      pageInfo {
        hasPreviousPage
        hasNextPage
      }
    }
  }
}
"""
    
    var organizationSlug: String
    var perPage: Int
    var cursor: String?
    var search: String?
    var teamSlug: String?
    var onlyFavorites: Bool?
    
    var resource: GraphQL<Response> {
        let variables: [String: JSONValue] = [
            "organization": .string(organizationSlug),
            "limit": .number(Double(perPage)),
            "cursor": cursor.map(JSONValue.init) ?? .null,
            "search": search.map(JSONValue.init) ?? .null,
            "team": teamSlug.map(JSONValue.init) ?? .null,
            "favorite": onlyFavorites.map(JSONValue.init) ?? .null,
        ]
        return GraphQL(rawQuery: PipelinesListQuery.query, variables: variables)
    }
    
    init(organizationSlug: String, perPage: Int, cursor: String? = nil, search: String? = nil, teamSlug: String? = nil, onlyFavorites: Bool? = nil) {
        self.organizationSlug = organizationSlug
        self.perPage = perPage
        self.cursor = cursor
        self.search = search
        self.teamSlug = teamSlug
        self.onlyFavorites = onlyFavorites
    }

    struct Response: Decodable {
        var organization: Organization
        
        struct Organization: Decodable {
            var pipelines: Connection<Pipeline>
            
            struct Pipeline: HashableFromIdentifier, Decodable {
                var id: String
                var name: String
                var defaultBranch: String
                var metrics: Connection<Metric>
                var builds: Connection<Build>
                
                struct Metric: HashableFromIdentifier, Decodable {
                    var id: String
                    var label: String
                    var value: String?
                }
                
                struct Build: HashableFromIdentifier, Decodable {
                    var id: String
                    var uuid: UUID
                    var number: Int
                    var url: URL
                    var state: State
                    var startedAt: Date?
                    var finishedAt: Date?
                    
                    enum State: String, Decodable {
                        /// The build was skipped
                        case skipped = "SKIPPED"
                        /// The build has yet to start running jobs
                        case scheduled = "SCHEDULED"
                        /// The build is currently running jobs
                        case running = "RUNNING"
                        /// The build passed
                        case passed = "PASSED"
                        /// The build failed
                        case failed = "FAILED"
                        /// The build is currently being canceled
                        case canceling = "CANCELING"
                        /// The build was canceled
                        case canceled = "CANCELED"
                        /// The build is blocked
                        case blocked = "BLOCKED"
                        /// The build wasn't run
                        case notRun = "NOT_RUN"

                    }
                }
            }
        }
    }
}


