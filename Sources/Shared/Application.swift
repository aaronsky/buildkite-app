//
//  Application.swift
//  Shared
//
//  Created by Aaron Sky on 6/25/20.
//

import SwiftUI

@main
struct Application: App {
    @Environment(\.emojis) var emojis
    @StateObject private var service = BuildkiteService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await emojis.load(service: service)
                }
                .environmentObject(service)
        }
    }
}
