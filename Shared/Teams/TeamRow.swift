//
//  TeamRow.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/25/20.
//

import SwiftUI
import Buildkite

struct TeamRow: View {
    @EnvironmentObject var emojis: Emojis
    
    var team: Team
    
    var body: some View {
        Text(team.name.replacingEmojis(using: emojis))
    }
}

struct TeamRow_Previews: PreviewProvider {
    static let teams = [Team](assetNamed: "v2.teams")!
    
    static var previews: some View {
        Group {
            TeamRow(team: teams[0])
            TeamRow(team: teams[1])
        }
        .frame(width: 250, alignment: .leading)
        .padding(.horizontal)
        .previewLayout(.sizeThatFits)
        .environmentObject(BuildkiteService())
    }
}
