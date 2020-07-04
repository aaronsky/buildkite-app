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
    @State private var selection: Agent?
    
    var body: some View {
        List(selection: $selection) {
            if agents.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else {
                ForEach(agents) { agent in
                    NavigationLink(destination: AgentView(agent: agent)) {
                        AgentRow(agent: agent)
                    }
                }
            }
        }
        .onAppear(perform: loadAgents)
        .navigationTitle("Agents")
    }
    
    func loadAgents() {
        let resource = Agent.Resources.List(organization: service.organization)
        service
            .allPagesPublisher(resource: resource, perPage: 100)
            .collect()
            .map { $0.flatMap { $0 } }
            .receive(on: DispatchQueue.main)
            .sink(into: service,
                  receiveValue: { self.agents = $0 })
    }
}

struct AgentsList_Previews: PreviewProvider {
    static let agents = [Agent](assetNamed: "v2.agents")
    
    static var previews: some View {
        AgentsList(agents: agents)
            .environmentObject(BuildkiteService())
    }
}
