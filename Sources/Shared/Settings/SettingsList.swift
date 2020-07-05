//
//  SettingsList.swift
//  Buildkite
//
//  Created by Aaron Sky on 7/3/20.
//

import SwiftUI

struct SettingsList: View {
    var body: some View {
        List {
            NavigationLink(destination: ChangelogList()) {
                Text("Changelog")
//                if viewer.hasUnreadChangelogs {
//                    Text("< NEW")
//                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct SettingsList_Previews: PreviewProvider {
    static var previews: some View {
        SettingsList()
    }
}
