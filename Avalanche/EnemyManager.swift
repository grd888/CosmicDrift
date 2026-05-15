//
//  EnemyManager.swift
//  Avalanche
//
//  Created by Greg Delgado on 15/5/2026.
//

import SpriteKit

enum EnemyType {
    case normal
    case seeker
}

class EnemyNode: SKSpriteNode {
    var type: EnemyType

    init(type: EnemyType, texture: SKTexture) {
        self.type = type
        super.init(texture: texture, color: .clear, size: texture.size())

        self.physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.usesPreciseCollisionDetection = true

        if type == .seeker {
            addGlowEffect()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateMovement(playerPosition: CGPoint) {
        switch type {
        case .normal:
            break
        case .seeker:
            let moveSpeed: CGFloat = 5
            if playerPosition.x > self.position.x {
                self.position.x += moveSpeed
            } else if playerPosition.x < self.position.x {
                self.position.x -= moveSpeed
            }
        }
    }

    private func addGlowEffect() {
        let glowAction = SKAction.colorize(with: .red, colorBlendFactor: 0.7, duration: 0.3)
        let removeGlow = SKAction.colorize(with: .white, colorBlendFactor: 0, duration: 0.3)

        let pulse = SKAction.sequence([glowAction, removeGlow])
        let repeatGlow = SKAction.repeatForever(pulse)

        self.run(repeatGlow)
    }
}
