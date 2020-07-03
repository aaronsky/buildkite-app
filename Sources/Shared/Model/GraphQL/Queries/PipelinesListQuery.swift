//
//  PipelinesListQuery.swift
//  Buildkite
//
//  Created by Aaron Sky on 7/1/20.
//

import Foundation
import Buildkite

struct PipelinesListQuery: GraphQLQuery {
    static var query = """
query PipelinesListQuery($organization: ID!, $pipelinesCount: Int, $pipelinesAfter: String, $pipelinesSearch: String, $buildsCount: Int, $buildsAfter: String) {
  organization(slug: $organization) {
    pipelines(first: $pipelinesCount, after: $pipelinesAfter, search: $pipelinesSearch) {
      edges {
        node {
          id
          uuid
          name
          url
          slug
          visibility
          builds(first: $buildsCount, after: $buildsAfter) {
            edges {
              node {
                id
                uuid
                number
                url
                state
                message
                branch
                commit
                createdAt
                createdBy {
                  ... on User {
                    name
                    email
                    avatar {
                      url
                    }
                  }
                  ... on UnregisteredUser {
                    name
                    email
                    avatar {
                      url
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
"""
    
    var organization: String
    var pipelinesCount: Int = 10
    var pipelinesAfter: String?
    var pipelinesSearch: String?
    var buildsCount: Int = 10
    var buildsAfter: String?
    
    var variables: [String: JSONValue] {
        var vars: [String: JSONValue] = [
            "organization": .string(organization),
            "pipelinesCount": .number(Double(pipelinesCount)),
            "buildsCount": .number(Double(buildsCount)),
        ]
        
        if let pipelinesAfter = pipelinesAfter { vars["pipelinesAfter"] = .string(pipelinesAfter) }
        if let pipelinesSearch = pipelinesSearch { vars["pipelinesSearch"] = .string(pipelinesSearch) }
        if let buildsAfter = buildsAfter { vars["buildsAfter"] = .string(buildsAfter) }
        
        return vars
    }
    
    struct Response: Decodable {
        var organization: Organization
        
        struct Organization: Decodable {
            var pipelines: Connection<Pipeline>
        }
        
        struct Pipeline: HashableFromIdentifier, Decodable {
            var id: String
            var uuid: UUID
            var name: String
            var url: URL
            var slug: String
            var visibility: Visibility
            var builds: Connection<Build>
            
            enum Visibility: String, Decodable {
                case `public` = "PUBLIC"
                case `private` = "PRIVATE"
            }
        }
        
        struct Build: HashableFromIdentifier, Decodable {
            var id: String
            var uuid: UUID
            var number: Int
            var url: URL
            var state: State
            var message: String?
            var branch: String
            var commit: String
            var createdAt: Date?
            var createdBy: User?
            
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
            
            struct User: Decodable {
                var name: String?
                var email: String?
                var avatar: Avatar
                
                struct Avatar: Decodable {
                    var url: URL
                }
            }
        }
    }
}
