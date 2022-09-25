import Buildkite
import Foundation
import GraphQLHelpers

public struct ListQuery: Query {
    public struct Response: Decodable, Equatable {
        public var viewer: ChangelogViewer

        public struct ChangelogViewer: Decodable, Equatable, Hashable {
            public var changelogs: Connection<Changelog>
        }

        public struct Changelog: Decodable, Equatable, Hashable, Identifiable {
            public var id: String
            public var title: String
            public var body: String
            public var publishedAt: Date
            public var tag: String
            public var author: ChangelogAuthor
        }

        public struct ChangelogAuthor: Decodable, Equatable, Hashable {
            public var name: String
            public var avatar: Fragments.Avatar
        }
    }

    public static let query: String = """
        query ChangelogList($first: Int, $last: Int, $read: Boolean) {
          viewer {
            changelogs(first: $first, last: $last, read: $read) {
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
                  title
                  body
                  publishedAt
                  tag
                  author {
                    avatar {
                      url
                    }
                    name
                  }
                }
              }
            }
          }
        }
        """

    public var first: Int?
    public var last: Int?
    public var read: Bool?

    public init(
        first: Int? = 100,
        last: Int? = nil,
        read: Bool? = nil
    ) {
        self.first = first
        self.last = last
        self.read = read
    }

    public var variables: [String: JSONValue] {
        [
            "first": first.map { .number(Double($0)) } ?? .null,
            "last": last.map { .number(Double($0)) } ?? .null,
            "read": read.map { .bool($0) } ?? .null,
        ]
    }
}
