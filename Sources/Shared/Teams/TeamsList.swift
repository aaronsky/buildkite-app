//
//  TeamsList.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/25/20.
//

import SwiftUI
import Buildkite

struct TeamsList: View {
    @EnvironmentObject var service: BuildkiteService

    @State var isLoading: Bool = false
    @State var teams: [Team] = []
    @State private var selection: Team?

    @ViewBuilder var body: some View {
#if os(iOS)
        content
#else
        content
#endif
    }

    var content: some View {
        List(selection: $selection) {
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if teams.isEmpty {
                Text("No teams found")
                    .italic()
            } else {
                ForEach(teams) { team in
                    NavigationLink(destination: TeamView(team: Fragments.Team(team: team))) {
                        TeamRow(team: team)
                    }
                }
            }
        }
        .listStyle(InsetListStyle())
        .task {
            await loadTeams()
        }
        .refreshable {
            await loadTeams()
        }
        .navigationTitle("Teams")
    }

    func loadTeams() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let pages = try await service.allPages(resource: .teams(in: service.organization), perPage: 50)
            self.teams = pages.flatMap { $0 }
        } catch {
            print(error)
        }
    }
}

struct TeamsList_Previews: PreviewProvider {
    static let teams = [Team](assetNamed: "v2.teams")

    static var previews: some View {
        TeamsList(teams: teams)
            .environmentObject(BuildkiteService())
            .environmentObject(Emojis())
    }
}
