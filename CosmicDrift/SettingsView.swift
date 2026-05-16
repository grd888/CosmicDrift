//
//  SettingsView.swift
//  CosmicDrift
//
//  Created by Greg Delgado on 16/5/2026.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Binding var showSettings: Bool
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [GameSettings]

    @State private var selectedShipColor: String = "red"
    @State private var shipScale: CGFloat = 1.0

    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()

            Text("Select Ship Color")
                .font(.headline)
                .padding(.top)

            Image("ship_\(selectedShipColor)")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .scaleEffect(shipScale)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: shipScale)

            Picker("Ship Color", selection: $selectedShipColor) {
                Text("Red").tag("red")
                Text("Purple").tag("purple")
                Text("Yellow").tag("yellow")
                Text("Silver").tag("silver")
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: selectedShipColor) { newValue in
                updateShipColor(newValue)
            }

            Spacer()
            Button(action: saveAndReturn) {
                Text("Save & Return")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .foregroundStyle(Color.white)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
        }
        .onAppear {
            selectedShipColor = settings.first?.selectedShipColor ?? "red"
        }


    }

    private func updateShipColor(_ color: String) {
        shipScale = 1.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            shipScale = 1.0
        }

        if settings.isEmpty {
            let newSettings = GameSettings(selectedShipColor: color)
            modelContext.insert(newSettings)
        } else {
            settings.first?.selectedShipColor = color
        }
        UserDefaults.standard.set(color, forKey: "selectedShipColor")
    }

    private func saveAndReturn() {
        Task {
            do {
                try modelContext.save()
            } catch {
                print("Failed to save: \(error)")
            }
            showSettings = false
        }
    }
}

#Preview {
    @Previewable @State var previewSettings = true
    return SettingsView(showSettings: $previewSettings)
}
