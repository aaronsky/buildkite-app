//
//  AgentRow.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/25/20.
//

import SwiftUI
import Buildkite

struct AgentRow: View {
    var agent: Agent

    var body: some View {
        HStack(alignment: .top) {
            ConnectionState(state: agent.connectionState, isRunningJob: agent.isRunningJob)
            VStack(alignment: .leading) {
                Text(agent.nameFormatted)
                    .font(.system(size: 15))
                Text(agent.metaData.joined(separator: ","))
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(agent.version)
                .font(.system(size: 14))
        }
    }
}

struct AgentRow_Previews: PreviewProvider {
    static let agent = Agent(assetNamed: "v2.agent")

    static var previews: some View {
        AgentRow(agent: agent)
    }
}
