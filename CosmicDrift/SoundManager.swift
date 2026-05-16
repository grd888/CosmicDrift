//
//  SoundManager.swift
//  CosmicDrift
//
//  Created by Greg Delgado on 14/5/2026.
//

import AVFoundation

class SoundManager {
    static let shared = SoundManager()

    var backgroundMusicPlayer: AVAudioPlayer?
    var soundEffectPlayer: AVAudioPlayer?

    private init() {}

    func playbackgroundMusic(filename: String, loop: Bool = true) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else {
            print("error: BGM not found \(filename)")
            return
        }
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = loop ? -1 : 0
            backgroundMusicPlayer?.volume = 0.1
            backgroundMusicPlayer?.play()
        } catch {
            print("error could not play BGM")
        }
    }

    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }

    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }

    func resumeBackgroundMusic() {
        backgroundMusicPlayer?.play()
    }

    func playSoundEffect(filename: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else {
            print("error: Sound effect file not found \(filename)")
            return
        }

        do {
            soundEffectPlayer = try AVAudioPlayer(contentsOf: url)
            soundEffectPlayer?.play()
        } catch {
            print("error could not play BGM")
        }
    }
}
