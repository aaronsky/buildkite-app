//
//  AppSidebarNavigation.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/25/20.
//

import SwiftUI

struct AppSidebarNavigation: View {
    @EnvironmentObject private var service: BuildkiteService
    @State private var selection: Set<NavigationItem> = [.pipelines]

    var sidebar: some View {
        List(selection: $selection) {
            ForEach(NavigationItem.allCases) { item in
                sidebarItem(for: item)
            }
        }
        .listStyle(SidebarListStyle())
    }

    var body: some View {
        NavigationView {
#if os(macOS)
            sidebar
                .frame(minWidth: 100, idealWidth: 150, maxWidth: 200, maxHeight: .infinity)
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

    func sidebarItem(for item: NavigationItem) -> some View {
        NavigationLink(destination: item.destination) {
            item.label
        }
        .accessibility(label: item.accessibilityLabel)
        .tag(item)
    }
}

struct AppSidebarNavigation_Previews: PreviewProvider {
    static var previews: some View {
        AppSidebarNavigation()
            .environmentObject(BuildkiteService())
    }
}
