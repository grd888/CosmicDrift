//
//  GameScene.swift
//  CosmicDrift
//
//  Created by Greg Delgado on 14/5/2026.
//

import SpriteKit
import AVFoundation
import SwiftUI // only needed for preview

class GameScene: SKScene, SKPhysicsContactDelegate {
    let player = SKSpriteNode(imageNamed: "ship")
    var enemyTextures: [SKTexture] = [
        SKTexture(imageNamed: "star"),
        SKTexture(imageNamed: "meteor"),
        SKTexture(imageNamed: "satalite")
    ]

    var background = SKSpriteNode(imageNamed: "space_background")
    var scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    var score = 0
    var gameOver = false
    var gameTimer: Timer?
    var scoreTimer: Timer?
    var shieldActive = false
    var powerUpTimer: Timer?
    var enemySpeedModifier: CGFloat = 1.0
    var gameTimeModifier: Double = 1.0

    func applyPowerUp(_ powerUp: PowerUp) {
        if let collectedEffect = SKEffectNode(fileNamed: "PowerUpEffect.sks") {
            collectedEffect.position = player.position
            collectedEffect.zPosition = 2
            addChild(collectedEffect)

            let removeAction = SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.removeFromParent()
            ])
            collectedEffect.run(removeAction)
        } else {
            print("effect not found")
        }

        switch powerUp.type {

        case .speedBoost:
            gameTimeModifier = 0.5
            enemySpeedModifier = 2.0

            restartScoreTimer()
            updateEnemySpeeds()

            // sound goes here
            let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
            player.run(SKAction.sequence([scaleUp, scaleDown]))
            run(SKAction.wait(forDuration: 5.0)) {
                self.gameTimeModifier = 1.0
                self.enemySpeedModifier = 1.0
                self.restartScoreTimer()
                self.updateEnemySpeeds()
            }
        case .slowEnemies:
            enemySpeedModifier = 0.5
            updateEnemySpeeds()

            run(SKAction.wait(forDuration: 5.0)) {
                self.enemySpeedModifier = 1.0
                self.updateEnemySpeeds()
            }
        case .shield:
            shieldActive = true
            let glow = SKShapeNode(circleOfRadius: 25)
            glow.strokeColor = .cyan
            glow.lineWidth = 4
            glow.alpha = 0.7
            glow.name = "shieldGlow"
            glow.position = CGPoint(x: 0, y: 0)
            player.addChild(glow)

            run(SKAction.wait(forDuration: 10.0)) {
                self.shieldActive = false
                glow.removeFromParent()
            }
        }
    }

    func updateEnemySpeeds() {
        for node in children {
            if let enemy = node as? SKSpriteNode, enemy.physicsBody?.categoryBitMask == 2 {
                let baseDuration: TimeInterval = 3.0
                let adjustedDuration = baseDuration / enemySpeedModifier

                enemy.removeAllActions()
                let moveAction = SKAction.moveTo(y: -enemy.size.height, duration: adjustedDuration)
                let removeAction = SKAction.removeFromParent()
                enemy.run(SKAction.sequence([moveAction, removeAction]))
            }
        }
    }

    func restartScoreTimer() {
        scoreTimer?.invalidate()
        scoreTimer = Timer.scheduledTimer(withTimeInterval: 1.0 * gameTimeModifier, repeats: true) { _ in
            if !self.gameOver {
                self.score += 1
                self.updateScoreLabel()
            }
        }
    }

    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupBackground()
        setupPlayer()
        setupUI()
        startGame()

        physicsWorld.contactDelegate = self

        // Sound here

    }

    func setupBackground() {
        background.size = self.size
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1
        addChild(background)
    }

    func setupPlayer() {
        player.position = CGPoint(x: size.width / 2, y: 120) // place us at the bottom
        player.size = CGSize(width: 40, height: 40)
        player.physicsBody = SKPhysicsBody(circleOfRadius: 20)
        player.physicsBody?.isDynamic = false // disables gravity
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.enemy | PhysicsCategory.powerUp
        addChild(player)
    }

    func setupUI() {
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 80)
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = .white
        addChild(scoreLabel)
        updateScoreLabel()
    }

    func startGame() {
        gameTimer?.invalidate()
        scoreTimer?.invalidate()
        powerUpTimer?.invalidate()

        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            self.spawnEnemy()
            self.moveEnemies()
            self.checkCollision()
        }
        scoreTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.score += 1
            self.updateScoreLabel()
        }

        powerUpTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            if !self.gameOver {
                self.spawnPowerUp()
            }
        }
        SoundManager.shared.playbackgroundMusic(filename: "game_music")
    }

    func spawnPowerUp() {
        let randomX = CGFloat.random(in: 50...size.width - 50)
        let powerUpType: PowerUpType
        let chance = Int.random(in: 1...3)

        switch chance {
        case 1:
            powerUpType = .speedBoost
        case 2:
            powerUpType = .slowEnemies
        default:
            powerUpType = .shield
        }

        let powerUp = PowerUp(type: powerUpType)
        powerUp.position = CGPoint(x: randomX, y: size.height)
        addChild(powerUp)

        let moveAction = SKAction.moveTo(y: -powerUp.size.height, duration: 4.0)
        let removeAction = SKAction.removeFromParent()
        powerUp.run(SKAction.sequence([moveAction, removeAction]))
    }

    func spawnEnemy() {
        let randomX = CGFloat.random(in: 50...size.width - 50)
        let randomSize = CGFloat.random(in: 20...35)

        // 50% dhance to spawn enemy each cycle
        if Bool.random() {


            let enemyType: EnemyType = Int.random(in: 1...10) == 1 ? .seeker : .normal
            let enemy = EnemyNode(type: enemyType, texture: enemyTextures.randomElement()!)
            enemy.position = CGPoint(x: randomX, y: size.height)
            enemy.size = CGSize(width: randomSize, height: randomSize)
            enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width / 2)
            enemy.physicsBody?.isDynamic = true
            enemy.physicsBody?.categoryBitMask = PhysicsCategory.enemy
            enemy.physicsBody?.contactTestBitMask = PhysicsCategory.player
            enemy.physicsBody?.collisionBitMask = 0
            enemy.physicsBody?.usesPreciseCollisionDetection = true
            addChild(enemy)

            let baseDuration: TimeInterval = 3.0
            let adjustedDuration = baseDuration / enemySpeedModifier

            let moveAction = SKAction.moveTo(y: -enemy.size.height, duration: adjustedDuration)
            let removeAction = SKAction.removeFromParent()
            enemy.run(SKAction.sequence([moveAction, removeAction]))
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB

        if (firstBody.categoryBitMask == PhysicsCategory.powerUp || secondBody.categoryBitMask == PhysicsCategory.powerUp) {
            if let powerUp = firstBody.node as? PowerUp ?? secondBody.node as? PowerUp {
                applyPowerUp(powerUp)

                if powerUp.parent != nil {
                    powerUp.removeFromParent()
                }
            }

            return
        }

        if (firstBody.categoryBitMask == PhysicsCategory.player || secondBody.categoryBitMask == PhysicsCategory.enemy) || (firstBody.categoryBitMask == PhysicsCategory.enemy && secondBody.categoryBitMask == PhysicsCategory.player) {

            if shieldActive {
                shieldActive = false

                if let shieldGlow = player.childNode(withName: "shieldGlow") {
                    let flash = SKAction.sequence([
                        SKAction.fadeOut(withDuration: 0.1),
                        SKAction.fadeIn(withDuration: 0.1),
                        SKAction.fadeOut(withDuration: 0.1),
                        SKAction.removeFromParent()
                    ])
                    shieldGlow.run(flash)
                }

                if firstBody.categoryBitMask == PhysicsCategory.enemy {
                    firstBody.node?.removeFromParent()
                } else {
                    secondBody.node?.removeFromParent()
                }
                return
            }

            print("Player")

            gameOver = true
            gameTimer?.invalidate()
            scoreTimer?.invalidate()
            powerUpTimer?.invalidate()
            showGameOver()

        }
    }

    func moveEnemies() {
        for node in children {
            if let enemy = node as? EnemyNode {
                let baseSpeed: CGFloat = size.height / (3.0 * 60)
                let adjustedSpeed = baseSpeed * enemySpeedModifier

                enemy.updateMovement(playerPosition: player.position)
                enemy.position.y -= adjustedSpeed

                if enemy.position.y < -enemy.size.height {
                    enemy.removeFromParent()
                }
            }
        }
    }

    func updateScoreLabel() {
        scoreLabel.text = "Timer Survived: \(score) seconds"
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        let clampedX = min(max(location.x, player.size.width / 2), size.width - player.size.width / 2)
        player.position.x = clampedX
    }

    func checkCollision() {
        for node in children {
            if node != player, let enemy = node as? SKSpriteNode, enemy.physicsBody?.categoryBitMask == PhysicsCategory.enemy {
                let distance = sqrt(pow(player.position.x - enemy.position.x, 2) + pow(player.position.y - enemy.position.y, 2))
                if distance < (enemy.size.width / 2 + 20) {
                    if shieldActive {
                        shieldActive = false
                        return
                    }
                    gameOver = true
                    gameTimer?.invalidate()
                    scoreTimer?.invalidate()
                    powerUpTimer?.invalidate()
                    showGameOver()
                }
            }
        }
    }

    func showGameOver() {
        showExplosion(at: player.position)
        SoundManager.shared.playSoundEffect(filename: "game_over")
        player.removeFromParent()

        showGameOverScreen()
    }

    func showExplosion(at position: CGPoint) {
        if let explosion = SKEmitterNode(fileNamed: "Explosion.sks") {
            explosion.position = position
            addChild(explosion)
            SoundManager.shared.playSoundEffect(filename: "explosion")
            run(SKAction.wait(forDuration: 1.0)) {
                explosion.removeFromParent()
            }
        }
    }

    func restartGame() {
        for node in children {
            if node != background && node != player {
                node.removeFromParent()
            }
        }
        shieldActive = false
        enemySpeedModifier = 1.0
        gameTimeModifier = 1.0
        gameOver = false
        score = 0

        updateScoreLabel()
        if !children.contains(player) {
            setupPlayer()
            setupUI()
            startGame()
        }
    }

    func showGameOverScreen() {
        gameTimer?.invalidate()
        scoreTimer?.invalidate()
        powerUpTimer?.invalidate()
        SoundManager.shared.stopBackgroundMusic()

        let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.6), size: self.size)
        overlay.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        overlay.zPosition = 10
        addChild(overlay)

        let gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 40
        gameOverLabel.fontColor = .white
        gameOverLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 + 80)
        gameOverLabel.zPosition = 11
        addChild(gameOverLabel)

        let retryButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        retryButton.text = "Go Again"
        retryButton.fontSize = 28
        retryButton.fontColor = .green
        retryButton.position = CGPoint(x: self.size.width / 2 - 100, y: self.size.height / 2 - 30)
        retryButton.zPosition = 11
        retryButton.name = "retryButton"
        addChild(retryButton)

        let finalScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        finalScoreLabel.text = "Final Score: \(score) seconds"
        finalScoreLabel.fontSize = 28
        finalScoreLabel.fontColor = .white
        finalScoreLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2 + 30)
        finalScoreLabel.zPosition = 11
        addChild(finalScoreLabel)

        let mainMenuButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        mainMenuButton.text = "Main Menu"
        mainMenuButton.fontSize = 28
        mainMenuButton.fontColor = .yellow
        mainMenuButton.position = CGPoint(x: self.size.width / 2 + 100, y: self.size.height / 2 - 30)
        mainMenuButton.zPosition = 11
        mainMenuButton.name = "mainMenuButton"
        addChild(mainMenuButton)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)

        if touchedNode.name == "mainMenuButton" {
            goToMainMenu()
        } else if touchedNode.name == "retryButton" {
            restartGame()
        }
    }

    func goToMainMenu() {
        gameTimer?.invalidate()
        scoreTimer?.invalidate()
        powerUpTimer?.invalidate()
        SoundManager.shared.stopBackgroundMusic()

        self.removeAllActions()
        self.removeAllChildren()

        NotificationCenter.default.post(name: NSNotification.Name("exitToMainMenu"), object: nil)
    }

}

#Preview {
    GameView()
}
