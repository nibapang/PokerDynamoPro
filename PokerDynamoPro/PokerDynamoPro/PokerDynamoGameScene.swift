//
//  GameScene.swift
//  PokerDynamoPro
//
//  Created by jin fu on 2025/3/10.
//


import UIKit
import SpriteKit

class PokerDynamoGameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Categories
    let playerCategory: UInt32 = 0x1 << 0
    let tokenCategory: UInt32 = 0x1 << 1
    let obstacleCategory: UInt32 = 0x1 << 2
    let groundCategory: UInt32 = 0x1 << 3
    let bombCategory: UInt32 = 0x1 << 4
    
    // MARK: - Game Elements
    private var player: SKSpriteNode!
    private var ground: SKSpriteNode!
    private var backgrounds: [SKSpriteNode] = []
    private var isJumping = false
    private var playerRunningFrames: [SKTexture] = []
    private var scoreLabel: SKLabelNode!
    private var bombLight: SKSpriteNode?
    private var bombBeepSound: SKAction?
    private var lives = 6
    private var livesLabel: SKLabelNode!
    
    var setGameOver: (() -> Void)?
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        setupPhysics()
        setupBackground()
        setupGround()
        setupPlayer()
        setupScoreLabel()
        setupTokenGenerator()
        setupObstacleGenerator()
        setupBombGenerator()
        setupLivesLabel()
    }
    
    private func setupPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
    }
    
    private func setupBackground() {
        // Create background that fills the entire view height
        for i in 0...1 {
            let background = SKSpriteNode(imageNamed: "background")
            background.anchorPoint = CGPoint.zero
            background.position = CGPoint(x: CGFloat(i) * background.size.width, y: 0)
            background.zPosition = -1
            background.name = "background"
            
            let scale = size.height / background.size.height
            background.setScale(scale)
            
            addChild(background)
            backgrounds.append(background)
        }
        
        let moveBackground = SKAction.run { [weak self] in
            self?.moveBackground()
        }
        
        let wait = SKAction.wait(forDuration: 0.01)
        run(SKAction.repeatForever(SKAction.sequence([moveBackground, wait])))
    }
    
    private func moveBackground() {
        for (index, background) in backgrounds.enumerated() {
            background.position.x -= 0.8
            
            if background.position.x <= -background.size.width {
                // Ensure the new position aligns perfectly without gaps
                let lastBackground = backgrounds[(index + backgrounds.count - 1) % backgrounds.count]
                background.position.x = lastBackground.position.x + lastBackground.size.width - 10
            }
        }
    }
    
    private func setupGround() {
        ground = SKSpriteNode(color: .brown, size: CGSize(width: size.width, height: 50))
        ground.position = CGPoint(x: size.width/2, y: 25)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = groundCategory
        ground.physicsBody?.contactTestBitMask = playerCategory
        ground.physicsBody?.collisionBitMask = playerCategory
        addChild(ground)
    }
    
    private func setupPlayer() {
        if let frames = UIImage.framesFromGif(named: "run") {
            playerRunningFrames = frames.map { SKTexture(image: $0) }
            player = SKSpriteNode(texture: playerRunningFrames.first)
        } else {
            player = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
        }
        
        player.size = CGSize(width: 60, height: 60)
        player.position = CGPoint(x: size.width * 0.2, y: ground.position.y + ground.size.height/2 + player.size.height/2)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.restitution = 0
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = tokenCategory | obstacleCategory | groundCategory | bombCategory
        player.physicsBody?.collisionBitMask = groundCategory
        
        addChild(player)
        startRunningAnimation()
    }
    
    private func startRunningAnimation() {
        guard !playerRunningFrames.isEmpty else { return }
        let animation = SKAction.animate(with: playerRunningFrames, timePerFrame: 0.1)
        player.run(SKAction.repeatForever(animation), withKey: "running")
    }
    
    private func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "ShortBaby")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        scoreLabel.position = CGPoint(x: size.width * 0.9, y: size.height * 0.9)
        addChild(scoreLabel)
    }
    
    private func setupTokenGenerator() {
        let generateToken = SKAction.run { [weak self] in
            self?.spawnToken()
        }
        let wait = SKAction.wait(forDuration: 2.0)
        run(SKAction.repeatForever(SKAction.sequence([generateToken, wait])))
    }
    
    private func setupObstacleGenerator() {
        let generateObstacle = SKAction.run { [weak self] in
            self?.spawnObstacle()
        }
        let wait = SKAction.wait(forDuration: 3.0)
        run(SKAction.repeatForever(SKAction.sequence([generateObstacle, wait])))
    }
    
    private func setupBombGenerator() {
        let generateBomb = SKAction.run { [weak self] in
            self?.spawnBomb()
        }
        let wait = SKAction.wait(forDuration: 5.0)
        run(SKAction.repeatForever(SKAction.sequence([generateBomb, wait])))
    }
    
    private func spawnBomb() {
        let bomb = SKSpriteNode(imageNamed: "bomb")
        bomb.size = CGSize(width: 40, height: 40)
        
        let minY = ground.position.y + ground.size.height/2 + 40
            let maxY = ground.position.y + ground.size.height/2 + 120
            
            bomb.position = CGPoint(x: size.width + bomb.size.width + CGFloat.random(in: 100...300),
                                    y: CGFloat.random(in: minY...maxY))
        
        bomb.physicsBody = SKPhysicsBody(circleOfRadius: bomb.size.width/2)
        bomb.physicsBody?.isDynamic = false
        bomb.physicsBody?.categoryBitMask = bombCategory
        bomb.physicsBody?.contactTestBitMask = playerCategory
        bomb.name = "bomb"
        
        // Add beeping light effect
        let light = SKSpriteNode(color: .red, size: CGSize(width: 20, height: 20))
        light.position = CGPoint(x: 0, y: 0)
        light.alpha = 0
        bomb.addChild(light)
        bombLight = light
        
        addChild(bomb)
        
        // Create beeping animation but don't start it yet
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.3)
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.3)
        let beepSound = SKAction.playSoundFileNamed("beep.mp3", waitForCompletion: false)
        let beepSequence = SKAction.sequence([fadeIn, beepSound, fadeOut])
        let repeatBeep = SKAction.repeatForever(beepSequence)
        
        // Store the beep action for later use
        bomb.userData = NSMutableDictionary()
        bomb.userData?.setValue(repeatBeep, forKey: "beepAction")
        
        let moveLeft = SKAction.moveBy(x: -size.width - bomb.size.width * 2 - 300, y: 0, duration: 4.0)
        let remove = SKAction.removeFromParent()
        bomb.run(SKAction.sequence([moveLeft, remove]))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Prevent player from moving left beyond the screen edge
        if player.position.x < player.size.width / 2 {
            player.position.x = player.size.width / 2
        }
        
        // Keep the bomb warning beeping logic
        enumerateChildNodes(withName: "bomb") { [weak self] bomb, _ in
            guard let self = self else { return }
            
            let distance = abs(bomb.position.x - self.player.position.x)
            let beepingRange: CGFloat = 200
            
            if distance < beepingRange {
                if bomb.action(forKey: "beeping") == nil,
                   let beepAction = bomb.userData?.value(forKey: "beepAction") as? SKAction {
                    bomb.run(beepAction, withKey: "beeping")
                    if let light = bomb.children.first as? SKSpriteNode {
                        light.alpha = 1.0 - (distance / beepingRange)
                    }
                }
            } else {
                bomb.removeAction(forKey: "beeping")
                if let light = bomb.children.first as? SKSpriteNode {
                    light.alpha = 0
                }
            }
        }
    }
    
    private func spawnToken() {
        let tokenTypes = ["token1", "token2", "token3", "token4"]
        guard let tokenType = tokenTypes.randomElement() else { return }
        
        let token = SKSpriteNode(imageNamed: tokenType)
        token.size = CGSize(width: 30, height: 30)

        // Ensure tokens spawn at a height the player can reach
        let minY = ground.position.y + ground.size.height + 30
        let maxY = minY + 80 // Within jumping range

        token.position = CGPoint(x: size.width + token.size.width, y: CGFloat.random(in: minY...maxY))
        
        token.physicsBody = SKPhysicsBody(circleOfRadius: token.size.width/2)
        token.physicsBody?.isDynamic = false
        token.physicsBody?.categoryBitMask = tokenCategory
        token.physicsBody?.contactTestBitMask = playerCategory
        token.name = "token"
        
        addChild(token)
        
        let moveLeft = SKAction.moveBy(x: -size.width - token.size.width * 2, y: 0, duration: 5.0)
        let remove = SKAction.removeFromParent()
        token.run(SKAction.sequence([moveLeft, remove]))
    }
    
    private func spawnObstacle() {
        let obstacle = SKSpriteNode(color: .lightGray, size: CGSize(width: 30, height: 30))
        obstacle.position = CGPoint(x: size.width + obstacle.size.width,
                                  y: ground.position.y + ground.size.height/2 + obstacle.size.height/2)
        
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.isDynamic = false
        obstacle.physicsBody?.contactTestBitMask = playerCategory
        obstacle.name = "obstacle"
        
        addChild(obstacle)
        
        let moveLeft = SKAction.moveBy(x: -size.width - obstacle.size.width * 2, y: 0, duration: 4.0)
        let remove = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([moveLeft, remove]))
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isJumping else {
            player.physicsBody?.velocity = CGVector(dx: 0, dy: -500)
            return
        }
        
        isJumping = true
        player.physicsBody?.velocity = CGVector(dx: 10, dy: 1000)
        player.removeAction(forKey: "running")
    }
    
    // MARK: - Physics Contact
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == playerCategory | groundCategory {
            isJumping = false
            startRunningAnimation()
        }
        
        if collision == playerCategory | tokenCategory {
            if let token = contact.bodyA.node?.name == "token" ? contact.bodyA.node : contact.bodyB.node {
                collectToken(token)
            }
        }
        
        if collision == playerCategory | bombCategory {
            if let bomb = contact.bodyA.node?.name == "bomb" ? contact.bodyA.node : contact.bodyB.node {
                collectBomb(bomb)
            }
        }
        
        if collision == playerCategory | obstacleCategory {
            gameOver()
        }
    }
    
    private func collectToken(_ token: SKNode) {
        score += 10
        scoreLabel.text = "Score: \(score)"
        token.removeFromParent()
    }
    
    private func collectBomb(_ bomb: SKNode) {
        
        loseLife()
        
        bomb.removeAction(forKey: "beeping")
        bomb.removeFromParent()
        
        // Add bomb power-up effect
        let powerUpEffect = SKEmitterNode(fileNamed: "BombPowerUp")
        powerUpEffect?.position = player.position
        powerUpEffect?.particleLifetime = 1.0
        addChild(powerUpEffect!)
        
        // Remove effect after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            powerUpEffect?.removeFromParent()
        }
    }
    
    private func loseLife() {
        if lives > 0 {
            lives -= 1
            livesLabel.text = String(repeating: "♥", count: lives)
            
            if lives == 0 {
                gameOver()
            }
        }
    }
    
    private func setupLivesLabel() {
        livesLabel = SKLabelNode(fontNamed: "ShortBaby")
        livesLabel.text = "♥♥♥♥♥♥"
        livesLabel.fontSize = 24
        livesLabel.position = CGPoint(x: size.width * 0.3, y: size.height * 0.9)
        addChild(livesLabel)
    }
    
    private func gameOver() {
        isPaused = true
        
        let gameOverLabel = SKLabelNode(fontNamed: "ShortBaby")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 40
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(gameOverLabel)
        
        setGameOver?()
    }
    
}
