//
//  AppTabNavigation.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/25/20.
//

import SwiftUI

struct AppTabNavigation: View {
    @State private var selection: NavigationItem = .pipelines

    var body: some View {
        TabView(selection: $selection) {
            ForEach(NavigationItem.allCases) { item in
                tab(for: item)
            }
        }
    }
    
    func tab(for item: NavigationItem) -> some View {
        NavigationView {
            item.destination
        }.tabItem {
            item.label
                .accessibility(label: item.accessibilityLabel)
        }.tag(item)
        
    }
}

struct AppTabNavigation_Previews: PreviewProvider {
    static var previews: some View {
        AppTabNavigation()
            .environmentObject(BuildkiteService())
            .environmentObject(Emojis(cache: ImageMemoryCache()))
    }
}
