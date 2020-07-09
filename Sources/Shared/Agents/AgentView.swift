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
    
    private var stopAgentPublisher = PassthroughSubject<Void, Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    init(agent: Agent) {
        _agent = State(initialValue: agent)
    }
    
    @ViewBuilder var body: some View {
        content
            .navigationTitle(agent.nameFormatted)
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button(action: stopAgent) {
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
        .onAppear(perform: loadAgent)
        .onReceive(stopAgentPublisher) { _ in
            isStoppingAgent = true
        }
    }
    
    func loadAgent() {
        Timer.publish(every: 3, on: .main, in: .default)
            .autoconnect()
            .flatMap { _ in
                service
                    .sendPublisher(resource: Agent.Resources.Get(organization: service.organization,
                                                                 agentId: agent.id))
            }
            .receive(on: DispatchQueue.main)
            .sink(into: service,
                  receiveValue: { self.agent = $0 })
    }
    
    func stopAgent() {
        service
            .sendPublisher(resource: Agent.Resources.Stop(organization: service.organization,
                                                          agentId: agent.id,
                                                          body: Agent.Resources.Stop.Body()))
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCompletion: { _ in })
            .catch { _ in Just(()) }
            .subscribe(stopAgentPublisher)
            .store(in: service)
    }
}

struct AgentView_Previews: PreviewProvider {
    static let agent = Agent(assetNamed: "v2.agent")
    
    static var previews: some View {
        AgentView(agent: agent)
            .environmentObject(BuildkiteService())
    }
}
