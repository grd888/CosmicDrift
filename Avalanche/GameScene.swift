//
//  GameScene.swift
//  Avalanche
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

    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupBackground()
        setupPlayer()
        setupUI()
        startGame()

        physicsWorld.contactDelegate = self

        // Sound here
        SoundManager.shared.playbackgroundMusic(filename: "game_music")
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
        player.physicsBody?.categoryBitMask = 1
        player.physicsBody?.contactTestBitMask = 2
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
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            self.spawnEnemy()
            self.moveEnemies()
            self.checkCollision()
        }
        scoreTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.score += 1
            self.updateScoreLabel()
        }
    }

    func spawnEnemy() {
        let randomX = CGFloat.random(in: 50...size.width - 50)
        let randomSize = CGFloat.random(in: 20...35)

        // 50% dhance to spawn enemy each cycle
        if Bool.random() {
            let enemy = SKSpriteNode(texture: enemyTextures.randomElement())
            enemy.position = CGPoint(x: randomX, y: size.height)
            enemy.size = CGSize(width: randomSize, height: randomSize)
            enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width)
            enemy.physicsBody?.isDynamic = true
            enemy.physicsBody?.categoryBitMask = 2
            enemy.physicsBody?.contactTestBitMask = 1
            enemy.physicsBody?.collisionBitMask = 0
            enemy.physicsBody?.usesPreciseCollisionDetection = true
            addChild(enemy)

            let moveAction = SKAction.moveTo(y: -enemy.size.height, duration: 3.0)
            let removeAction = SKAction.removeFromParent()
            enemy.run(SKAction.sequence([moveAction, removeAction]))
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA.categoryBitMask
        let secondBody = contact.bodyB.categoryBitMask

        if (firstBody == 1 && secondBody == 2) || (firstBody == 2 && secondBody == 1) {
            gameOver = true
            gameTimer?.invalidate()
            showGameOver()
        }
    }

    func moveEnemies() {
        for node in children {
            if let sprite = node as? SKSpriteNode, sprite != player, sprite != background {
                sprite.position.y -= 30
                if sprite.position.y < 0 {
                    sprite.removeFromParent()
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

        let clampedX = min(max(location.x, player.size.width / 2), size.width - size.width / 2)
        player.position.x = clampedX
    }

    func checkCollision() {
        for node in children {
            if node != player, let enemy = node as? SKSpriteNode {
                let distance = sqrt(pow(player.position.x - enemy.position.x, 2) + pow(player.position.y - enemy.position.y, 2))
                if distance < (enemy.size.width / 2 + 20) {
                    gameOver = true
                    gameTimer?.invalidate()
                    scoreTimer?.invalidate()
                    showGameOver()
                }
            }
        }
    }

    func showGameOver() {
        showExplosion(at: player.position)
        SoundManager.shared.playSoundEffect(filename: "game_over")
        player.removeFromParent()
        run(SKAction.wait(forDuration: 2.0)) {
            self.restartGame()
        }
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
        gameOver = false
        score = 0

        updateScoreLabel()
        if !children.contains(player) {
            setupPlayer()
            setupUI()
            startGame()
        }
    }

}

#Preview {
    GameView()
}
