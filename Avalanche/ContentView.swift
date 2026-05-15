//
//  ContentView.swift
//  Avalanche
//
//  Created by Greg Delgado on 13/5/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var showGameScene: Bool = false

    var body: some View {
        ZStack {
            if showGameScene {
                GameView()
                    .id(UUID())
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("exitToMainMenu"))) { _ in
                        showGameScene = false
                    }
            } else {
                VStack {
                    Text("Avalanche")
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
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: showGameScene)
    }
}

#Preview {
    ContentView()
}
