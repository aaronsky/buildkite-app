//
//  Application.swift
//  Shared
//
//  Created by Aaron Sky on 6/25/20.
//

import SwiftUI
#if APPCLIP
import AppClip
import CoreLocation
#endif

@main
struct Application: App {
    @StateObject private var service = BuildkiteService()
    @StateObject private var emojis = Emojis(cache: ImageMemoryCache())
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear { emojis.loadEmojis(service: service) }
                .environmentObject(service)
                .environmentObject(emojis)
        }
    }

    #if APPCLIP
    func handleUserActivity(_ userActivity: NSUserActivity) {
        
    }
    #endif
}
