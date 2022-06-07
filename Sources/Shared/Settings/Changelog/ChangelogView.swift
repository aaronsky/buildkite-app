//
//  ChangelogView.swift
//  Buildkite
//
//  Created by Aaron Sky on 7/3/20.
//

import Buildkite
import SwiftUI

struct ChangelogView: View {
    typealias Changelog = ChangelogListQuery.Response.Changelog

    var changelog: Changelog

    var body: some View {
        VStack {
            Text(changelog.title)
                .font(.headline)
            Text("Posted \(changelog.publishedAt.formatted(.dateTime.month().day().year())) by \(changelog.author.name)")
                .font(.subheadline)
            Text(try! AttributedString(markdown: changelog.body))
                .font(.body)
            Text(changelog.tag)
                .font(.callout)
                .padding(7)
                .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.red))
        }
    }
}

struct ChangelogView_Previews: PreviewProvider {
    static var query = try! GraphQL<ChangelogListQuery.Response>.Content(assetNamed: "gql.ChangelogList").get()

    static var previews: some View {
        NavigationView {
            ChangelogView(changelog: query.viewer.changelogs.nodes.first!)
        }
        .environmentObject(BuildkiteService())
    }
}
