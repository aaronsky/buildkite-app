//
//  NavigationItem.swift
//  Buildkite
//
//  Created by Aaron Sky on 7/3/20.
//

import SwiftUI

enum NavigationItem: CaseIterable {
    case pipelines
    case agents
    case users
    case more

    @ViewBuilder var destination: some View {
        switch self {
        case .pipelines:
            PipelinesList()
        case .agents:
            AgentsList()
        case .users:
            UsersOrTeamsView()
        case .more:
            SettingsList()
        }
    }

    @ViewBuilder var label: some View {
        switch self {
        case .pipelines:
            Label("Pipelines", systemImage: "hammer.fill")
        case .agents:
            Label("Agents", systemImage: "ant.fill")
        case .users:
            Label("Users", systemImage: "person.3.fill")
        case .more:
            Label("More", systemImage: "ellipsis")
        }
    }

    var accessibilityLabel: Text {
        switch self {
        case .pipelines:
            return Text("Pipelines")
        case .agents:
            return Text("Agents")
        case .users:
            return Text("Users")
        case .more:
            return Text("More")
        }
    }
}

extension NavigationItem: Identifiable {
    var id: NavigationItem {
        self
    }
}

struct NavigationItem_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ForEach(NavigationItem.allCases) { item in
                NavigationLink(destination: item.destination) {
                    item.label
                        .accessibility(label: item.accessibilityLabel)
                }
                .tag(item)
            }
        }
    }
}
