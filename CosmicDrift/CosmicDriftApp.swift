//
//  CosmicDriftApp.swift
//  CosmicDrift
//
//  Created by Greg Delgado on 13/5/2026.
//

import SwiftUI
import SwiftData

@main
struct CosmicDriftApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([GameSettings.self])
        let container = try! ModelContainer(for: schema)
        return container
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
}
