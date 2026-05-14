//
//  GameView.swift
//  Avalanche
//
//  Created by Greg Delgado on 14/5/2026.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @Environment(\.scenePhase) private var scenePhase

    var scene: SKScene {
        let scene: SKScene = GameScene()
        scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scene.scaleMode = .fill
        return scene
    }
    var body: some View {
        SpriteView(scene: scene)
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)
            .onChange(of: scenePhase) { _, newPhase in
                switch newPhase {
                case .active: SoundManager.shared.resumeBackgroundMusic()
                case .inactive, .background: SoundManager.shared.pauseBackgroundMusic()
                @unknown default: break
                }
            }
    }
}

#Preview {
    GameView()
}
