//
//  AgentView.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/25/20.
//

import SwiftUI
import Combine
import Buildkite

struct AgentView: View {
    @EnvironmentObject var service: BuildkiteService
    
    @State var agent: Agent
    @State private var isStoppingAgent: Bool = false
    let agentStatusTimer = Timer.publish(every: 3, on: .main, in: .default).autoconnect()
    
    init(agent: Agent) {
        _agent = State(initialValue: agent)
    }
    
    @ViewBuilder var body: some View {
        content
            .navigationTitle(agent.nameFormatted)
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button(action: {
                        Task {
                            await stopAgent()
                        }
                    }) {
                        Text("Stop")
                    }.disabled(isStoppingAgent || agent.connectionState != "connected")
                }
            }
    }
    
    var content: some View {
        Form {
            Section {
                HStack {
                    Text("State")
                    Spacer()
                    ConnectionState(state: agent.connectionState, isRunningJob: agent.isRunningJob)
                    Text(agent.connectionState)
                }
                HStack {
                    Text("Version")
                    Spacer()
                    Text(agent.version)
                }
            }
            Section(header: Text("HOST")) {
                HStack {
                    Text("Hostname")
                    Spacer()
                    Text(agent.hostname)
                }
                HStack {
                    Text("IP Address")
                    Spacer()
                    Text(agent.ipAddress)
                }
                HStack {
                    Text("User Agent")
                    Spacer()
                    Text(agent.userAgent)
                }
                HStack {
                    Text("Connected")
                    Spacer()
                    Text("\(agent.createdAt, formatter: Formatters.friendlyRelativeDateFormatter)")
                }
            }
            Section(header: Text("TAGS")) {
                Text(agent.metaData.joined())
            }
        }
        .onReceive(agentStatusTimer) { _ in
            Task {
                await loadAgent()
            }
        }
        .task {
            await loadAgent()
        }
    }
    
    func loadAgent() async {
        let resource = Agent.Resources.Get(organization: service.organization,
                                           agentId: agent.id)
        guard let agent = try? await service.send(resource: resource) else {
            return
        }
        self.agent = agent
    }
    
    func stopAgent() async {
        isStoppingAgent = true
        try? await service.send(resource: Agent.Resources.Stop(organization: service.organization,
                                                    agentId: agent.id,
                                                    body: Agent.Resources.Stop.Body()))
    }
}

struct AgentView_Previews: PreviewProvider {
    static let agent = Agent(assetNamed: "v2.agent")
    
    static var previews: some View {
        AgentView(agent: agent)
            .environmentObject(BuildkiteService())
    }
}
