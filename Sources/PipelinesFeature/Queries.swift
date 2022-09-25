import Buildkite
import Foundation
import GraphQLHelpers

public struct ListQuery: Query {
    public struct Response: Decodable, Equatable, Hashable, Sendable {
        public var organization: Organization

        public struct Organization: Decodable, Equatable, Hashable, Sendable {
            public var pipelines: Connection<Pipeline>
        }

        public struct Pipeline: Decodable, Equatable, Hashable, Identifiable, Sendable {
            public var id: String
            public var uuid: UUID
            public var name: String
            public var url: URL
            public var slug: String
            public var visibility: Visibility
            public var builds: Connection<Build>

            public enum Visibility: String, Decodable, Equatable, Hashable, Sendable {
                case `public` = "PUBLIC"
                case `private` = "PRIVATE"
            }
        }

        public struct Build: Decodable, Equatable, Hashable, Identifiable, Sendable {
            public var id: String
            public var uuid: UUID
            public var number: Int
            public var url: URL
            public var state: State
            public var message: String?
            public var branch: String
            public var commit: String
            public var createdAt: Date?
            public var createdBy: Creator?
            public var finishedAt: Date?

            public enum State: String, Decodable, Equatable, Hashable, Sendable {
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

            public struct Creator: Decodable, Equatable, Hashable, Sendable {
                var name: String?
                var email: String?
                var avatar: Fragments.Avatar
            }
        }
    }

    public static let query: String = """
        query PipelinesListQuery($organization: ID!, $pipelinesCount: Int, $pipelinesAfter: String, $pipelinesSearch: String, $buildsCount: Int, $buildsAfter: String) {
          organization(slug: $organization) {
            pipelines(first: $pipelinesCount, after: $pipelinesAfter, search: $pipelinesSearch) {
              count
              pageInfo {
                endCursor
                hasNextPage
                hasPreviousPage
                startCursor
              }
              edges {
                cursor
                node {
                  id
                  uuid
                  name
                  url
                  slug
                  visibility
                  builds(first: $buildsCount, after: $buildsAfter) {
                    count
                    pageInfo {
                      endCursor
                      hasNextPage
                      hasPreviousPage
                      startCursor
                    }
                    edges {
                      cursor
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
                        finishedAt
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
    var pipelinesCount = 10
    var pipelinesAfter: String?
    var pipelinesSearch: String?
    var buildsCount = 10
    var buildsAfter: String?

    public var variables: [String: JSONValue] {
        [
            "organization": .string(organization),
            "pipelinesCount": .number(Double(pipelinesCount)),
            "buildsCount": .number(Double(buildsCount)),
            "pipelinesAfter": pipelinesAfter.map { .string($0) } ?? .null,
            "pipelinesSearch": pipelinesSearch.map { .string($0) } ?? .null,
            "buildsAfter": buildsAfter.map { .string($0) } ?? .null,
        ]
    }

    init(
        organization: String,
        pipelinesCount: Int = 10,
        pipelinesAfter: String? = nil,
        pipelinesSearch: String? = nil,
        buildsCount: Int = 10,
        buildsAfter: String? = nil
    ) {
        self.organization = organization
        self.pipelinesCount = pipelinesCount
        self.pipelinesAfter = pipelinesAfter
        self.pipelinesSearch = pipelinesSearch
        self.buildsCount = buildsCount
        self.buildsAfter = buildsAfter
    }
}
