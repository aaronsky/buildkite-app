import Buildkite
import Foundation
import GraphQLHelpers

public struct GetQuery: Query {
    public struct Response: Decodable, Equatable {
        var team: Fragments.Team
    }

    public static let query: String = """
        query TeamGet($slug: ID!, $first: Int!) {
          team(slug: $slug) {
            id
            name
            slug
            description
            privacy
            members(first: $first) {
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
        }
        """

    var slug: String
    var first = 100

    public var variables: [String: JSONValue] {
        [
            "slug": .string(slug),
            "first": .number(Double(first)),
        ]
    }

    init(
        slug: String,
        first: Int = 100
    ) {
        self.slug = slug
        self.first = first
    }
}
