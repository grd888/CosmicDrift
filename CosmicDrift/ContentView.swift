//
//  ContentView.swift
//  CosmicDrift
//
//  Created by Greg Delgado on 13/5/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var showGameScene: Bool = false
    @State private var showSettings = false

    var body: some View {
        ZStack {
            if showGameScene {
                GameView()
                    .id(UUID())
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("exitToMainMenu"))) { _ in
                        showGameScene = false
                    }
            } else if showSettings {
                SettingsView(showSettings: $showSettings)
            } else {
                VStack {
                    Text("Cosmic Drift")
                        .font(.title)
                        .padding()

                    Button(action: {
                        showGameScene = true
                    }) {
                        Text("Start Game")
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.blue)
                            .foregroundStyle(.white)
                    }

                    Button(action: {
                        showSettings = true
                    }) {
                        Text("Settings")
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.gray)
                            .foregroundStyle(.white)
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: showGameScene)
        .animation(.easeInOut, value: showSettings)
    }
}

#Preview {
    ContentView()
}
