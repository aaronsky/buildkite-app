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
    @State var agent: Agent
    
    @EnvironmentObject var service: BuildkiteService
    @Environment(\.presentationMode) var presentationMode
    
    var stopAgentPublisher = PassthroughSubject<Void, Never>()
    
    @ViewBuilder var body: some View {
        #if os(iOS)
        content
            .navigationBarTitle(Text(agent.nameFormatted), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: stopAgent) {
                Text("Stop")
            })
        #else
        content.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: stopAgent) {
                    Text("Stop")
                }
            }
        }
        #endif
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
        .onAppear(perform: reloadAgent)
        .onReceive(stopAgentPublisher) { _ in
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func reloadAgent() {
        service
            .sendPublisher(resource: Agent.Resources.Get(organization: service.organization, agentId: agent.id))
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
    static let agent = Agent(assetNamed: "v2.agent")!
    
    static var previews: some View {
        AgentView(agent: agent)
    }
}
