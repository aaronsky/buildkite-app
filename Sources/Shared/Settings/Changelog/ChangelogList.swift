//
//  ChangelogList.swift
//  Buildkite
//
//  Created by Aaron Sky on 7/3/20.
//

import Buildkite
import SwiftUI

struct ChangelogList: View {
    typealias Changelog = ChangelogListQuery.Response.Changelog
    
    @EnvironmentObject var service: BuildkiteService

    @State var changelogs: [Changelog] = []

    var body: some View {
        List(changelogs) { changelog in
            NavigationLink(destination: ChangelogView(changelog: changelog)) {
                HStack {
                    Text(changelog.publishedAt.formatted(.dateTime.month().day()))
                        .font(.footnote)
                    Text(changelog.title)
                    // Spacer()
                    // Text(changelog.tag)
                }
            }
        }
        .listStyle(InsetListStyle())
        .task {
            await loadChangelogs()
        }
        .refreshable {
            await loadChangelogs()
        }
        .navigationTitle("Changelogs")
    }

    func loadChangelogs() async {
        do {
            let data = try await service.sendQuery(ChangelogListQuery())
            self.changelogs = data.viewer.changelogs.nodes
        } catch {
            print(error)
        }
    }
}

struct ChangelogList_Previews: PreviewProvider {
    static var query = try! GraphQL<ChangelogListQuery.Response>.Content(assetNamed: "gql.ChangelogList").get()

    static var previews: some View {
        ChangelogList(changelogs: query.viewer.changelogs.nodes)
            .environmentObject(BuildkiteService())
    }
}
