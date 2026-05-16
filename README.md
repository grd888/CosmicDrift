# Cosmic Drift

A fast-paced iOS space survival game built with SwiftUI and SpriteKit. Pilot your ship through an endless cosmic gauntlet of meteors, satellites, and homing enemies — collect power-ups, survive as long as you can, and chase a high score.

---

## Features

- **SpriteKit physics** with precise collision detection
- **Two enemy behaviours** — normal and homing seekers
- **Three power-ups** with visual and audio feedback
- **Four ship skins** — Red, Purple, Yellow, Silver — selectable in Settings and persisted across sessions
- **Particle effects** on power-up collection and explosions
- **Background music and sound effects** (toggleable)
- **SwiftData persistence** for ship colour preference

---

## Requirements

- iOS 17 or later
- Xcode 15 or later
- Swift 5.9 or later


---


## Architecture Notes

The project uses a SwiftUI shell around a SpriteKit scene, following Apple's recommended pattern for hybrid apps:

- **SwiftUI** handles all navigation (main menu, settings, game-over overlay).
- **SpriteKit** owns the game loop, physics, and rendering inside `GameScene`.
- **SwiftData** stores the player's ship colour preference via `GameSettings`, injected through the SwiftUI environment.
- The game scene posts an `exitToMainMenu` `NotificationCenter` event when the player quits, which `ContentView` observes to return to the menu without tight coupling.

---

## License

This project is personal / educational software. All rights reserved.
