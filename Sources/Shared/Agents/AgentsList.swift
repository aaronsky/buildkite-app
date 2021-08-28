//
//  AgentsList.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/25/20.
//

import SwiftUI
import Buildkite

struct AgentsList: View {
    @EnvironmentObject var service: BuildkiteService

    @State var agents: [Agent] = []
    @State var isLoading: Bool = false
    @State private var selection: Agent?

    var body: some View {
        List(selection: $selection) {
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else if agents.isEmpty {
                Text("No agents available")
                    .italic()
            } else {
                ForEach(agents) { agent in
                    NavigationLink(destination: AgentView(agent: agent)) {
                        AgentRow(agent: agent)
                    }
                }
            }
        }
        .listStyle(InsetListStyle())
        .task {
            await loadAgents()
        }
        .refreshable {
            await loadAgents()
        }
        .navigationTitle("Agents")
    }

    func loadAgents() async {
        self.isLoading = true
        defer { self.isLoading = false }
        do {
            let pages = try await service.allPages(resource: .agents(in: service.organization), perPage: 100)
            self.agents = pages.flatMap { $0 }
        } catch {
            print(error)
        }

    }
}

struct AgentsList_Previews: PreviewProvider {
    static let agents = [Agent](assetNamed: "v2.agents")

    static var previews: some View {
        AgentsList(agents: agents)
            .environmentObject(BuildkiteService())
    }
}
