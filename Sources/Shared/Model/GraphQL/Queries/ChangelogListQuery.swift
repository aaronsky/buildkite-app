//
//  ChangelogListQuery.swift
//  Shared
//
//  Created by Aaron Sky on 8/29/21.
//

import Foundation
import Buildkite

struct ChangelogListQuery: GraphQLQuery {
    static var query = """
query ChangelogList($first: Int!) {
  viewer {
    changelogs(first: $first) {
      edges {
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

    var variables: [String : JSONValue] {
        [
            "first": 100
        ]
    }

    init() {}

    struct Response: Decodable {
        var viewer: ChangelogViewer

        struct ChangelogViewer: Decodable {
            var changelogs: Connection<Changelog>
        }

        struct Changelog: HashableFromIdentifier, Decodable {
            var id: String
            var title: String
            var body: String
            var publishedAt: Date
            var tag: String
            var author: ChangelogAuthor
        }

        struct ChangelogAuthor: Decodable {
            var name: String
            var avatar: Fragments.Avatar
        }
    }
}
