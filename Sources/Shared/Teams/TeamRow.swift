//
//  TeamRow.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/25/20.
//

import SwiftUI
import Buildkite

struct TeamRow: View {
    @Environment(\.emojis) var emojis

    var team: Team

    var body: some View {
        Text(team.name, emojis: emojis)
    }
}

struct TeamRow_Previews: PreviewProvider {
    static let teams = [Team](assetNamed: "v2.teams")

    static var previews: some View {
        List {
            TeamRow(team: teams[0])
            TeamRow(team: teams[1])
        }
        .frame(height: 150)
        .previewLayout(.sizeThatFits)
    }
}
