//
//  AppTabNavigation.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/25/20.
//

import SwiftUI

struct AppTabNavigation: View {
    enum Tab {
        case agents
        case pipelines
        case teams
    }
    
    @State private var selection: Tab = .agents

    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                AgentsList()
            }
            .tabItem {
                Label("Agents", systemImage: "ant.fill")
                    .accessibility(label: Text("Agents"))
            }
            .tag(Tab.agents)
            
            NavigationView {
                PipelinesList()
            }
            .tabItem {
                Label("Pipelines", systemImage: "hammer.fill")
                    .accessibility(label: Text("Pipelines"))
            }
            .tag(Tab.pipelines)
            
            NavigationView {
                TeamsList()
            }
            .tabItem {
                Label("Teams", systemImage: "person.3.fill")
                    .accessibility(label: Text("Teams"))
            }
            .tag(Tab.teams)
        }
    }
}

struct AppTabNavigation_Previews: PreviewProvider {
    static var previews: some View {
        AppTabNavigation()
    }
}
