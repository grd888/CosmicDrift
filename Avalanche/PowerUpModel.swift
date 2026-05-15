//
//  PowerUpModel.swift
//  Avalanche
//
//  Created by Greg Delgado on 15/5/2026.
//

import SpriteKit

enum PowerUpType {
    case speedBoost
    case slowEnemies
    case shield
}

class PowerUp: SKSpriteNode {
    let type: PowerUpType

    init(type: PowerUpType) {
        self.type = type

        let texture: SKTexture

        switch type {
        case .speedBoost:
            texture = SKTexture(imageNamed: "powerup_speed")
        case .slowEnemies:
            texture = SKTexture(imageNamed: "powerup_slow")
        case .shield:
            texture = SKTexture(imageNamed: "powerup_shield")
        }

        super.init(texture: texture, color: .clear, size: CGSize(width: 30, height: 30))

        self.physicsBody = SKPhysicsBody(circleOfRadius: 15)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = PhysicsCategory.powerUp
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player
        self.physicsBody?.collisionBitMask = 0
        self.zPosition = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
