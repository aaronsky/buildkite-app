//
//  Application.swift
//  Shared
//
//  Created by Aaron Sky on 6/25/20.
//

import SwiftUI

@main
struct Application: App {
    @StateObject private var service = BuildkiteService()
    @StateObject private var emojis = Emojis()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await emojis.load(service: service)
                }
                .environmentObject(service)
                .environmentObject(emojis)
        }
    }
}
