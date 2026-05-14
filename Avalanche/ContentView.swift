//
//  ContentView.swift
//  Avalanche
//
//  Created by Greg Delgado on 13/5/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Avalanche")
                    .font(.title)
                    .padding()

                NavigationLink(destination: GameView()) {
                    Text("Start Game")
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle.init(cornerRadius: 12))
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
