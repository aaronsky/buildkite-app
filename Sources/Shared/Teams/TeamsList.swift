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
            if teams.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
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
        .navigationTitle("Teams")
    }
    
    func loadTeams() async {
        let resource = Team.Resources.List(organization: service.organization)
        guard let response = try? await service.allPages(resource: resource, perPage: 50) else {
            return
        }
        self.teams = response.flatMap { $0 }
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
