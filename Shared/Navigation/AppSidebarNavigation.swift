//
//  AppSidebarNavigation.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/25/20.
//

import SwiftUI

struct AppSidebarNavigation: View {
    
    enum NavigationItem {
        case agents
        case pipelines
        case teams
    }
    
    @EnvironmentObject private var service: BuildkiteService
    @State private var selection: Set<NavigationItem> = [.pipelines]
    
    var sidebar: some View {
        List(selection: $selection) {            
            NavigationLink(destination: AgentsList()) {
                Label("Agents", systemImage: "ant.fill")
            }
            .accessibility(label: Text("Agents"))
            .tag(NavigationItem.agents)
            
            NavigationLink(destination: PipelinesList()) {
                Label("Pipelines", systemImage: "hammer.fill")
            }
            .accessibility(label: Text("Pipelines"))
            .tag(NavigationItem.pipelines)
            
            NavigationLink(destination: TeamsList()) {
                Label("Teams", systemImage: "person.3.fill")
            }
            .accessibility(label: Text("Teams"))
            .tag(NavigationItem.teams)
        }
        .listStyle(SidebarListStyle())
    }
    
    var body: some View {
        NavigationView {
            #if os(macOS)
            sidebar.frame(minWidth: 100, idealWidth: 150, maxWidth: 200, maxHeight: .infinity)
            #else
            sidebar
            #endif
            
            Text("No Content")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            #if os(macOS)
            Text("No Content Selected")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .toolbar { Spacer() }
            #else
            Text("No Content Selected")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            #endif
        }
    }
}

struct AppSidebarNavigation_Previews: PreviewProvider {
    static var previews: some View {
        AppSidebarNavigation()
            .environmentObject(BuildkiteService())
    }
}
