//
//  GameScene.swift
//  SpaceDefender
//
//  Created by MacBookPro on 10.10.2018.
//  Copyright © 2018 MacBookPro. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var healthLabel: SKLabelNode!
    
    var score: UInt = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var health: Int = 5 {
        didSet {
            healthLabel.text = "Health: \(health)"
        }
    }
    var gameTimer: Timer!
    var aliens = ["alien", "alien2", "alien3"]
    
    let playerCategory: UInt32 = 1
    let alienCategory: UInt32 = 2
    let bulletCategory: UInt32 = 3
    
    
    let motionManager = CMMotionManager()
    var xAccelerate: CGFloat = 0
    
    override func didMove(to view: SKView) {
        starfield = SKEmitterNode(fileNamed: "Starfield.sks")
        starfield.position = CGPoint(x: frame.minX, y: frame.maxY)
        starfield.advanceSimulationTime(5)
        self.addChild(starfield)
        
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "shuttle")
        player.name = "player"
        player.position = CGPoint(x: frame.midX, y: frame.minY + 40)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.collisionBitMask = alienCategory
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0) // disabling gravity
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "HelveticaNeue-Bold"
        scoreLabel.fontSize = 15
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: frame.maxX*0.1, y: frame.maxY - frame.maxY*0.05)
        score = 0
        self.addChild(scoreLabel)
        
        healthLabel = SKLabelNode(text: "Health: 5")
        healthLabel.fontSize = 15
        healthLabel.fontName = "HelveticaNeue-Bold"
        healthLabel.fontColor = UIColor.white
        healthLabel.position = CGPoint(x: frame.maxX*0.9, y: frame.maxY - frame.maxY*0.05)
        health = 5
        
        self.addChild(healthLabel)
        
        var timeInterval = 0.75
        
        if UserDefaults.standard.bool(forKey: "hard") {
            timeInterval = 0.3
        }
        
        let wait = SKAction.wait(forDuration:timeInterval)
        let action = SKAction.run {
            self.addAliens()
        }
        run(SKAction.repeatForever(SKAction.sequence([wait, action])))
        
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            if let accelerometrData = data {
                let acceleration = accelerometrData.acceleration
                self.xAccelerate = CGFloat(acceleration.x) * 0.75 + self.xAccelerate * 0.25
            }
        }
    }
    
    override func didSimulatePhysics() {
        player.position.x += xAccelerate * 25
        
        if player.position.x < 0 {
            player.position = CGPoint(x: frame.maxX - player.size.width, y: player.position.y)
        } else if player.position.x > frame.maxX {
            player.position = CGPoint(x: player.size.width, y: player.position.y)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        collisionElements(firstNode: contact.bodyA.node as! SKSpriteNode, secondNode: contact.bodyB.node as! SKSpriteNode)
    }
    
    func collisionElements(firstNode: SKSpriteNode, secondNode: SKSpriteNode) {
        if firstNode.name == "bullet" || secondNode.name == "bullet" {
            let explosion = SKEmitterNode(fileNamed: "Explosion")
            explosion?.position = firstNode.name == "bullet" ? secondNode.position : firstNode.position
            self.addChild(explosion!)
            self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
            
            firstNode.removeFromParent()
            secondNode.removeFromParent()
            self.run(SKAction.wait(forDuration: 2)) {
                explosion?.removeFromParent()
            }
            
            score += 5
        } else if firstNode.name == "player" || secondNode.name == "player" {
            health -= 1
            firstNode.name == "player" ? secondNode.removeFromParent() : firstNode.removeFromParent()
            let explosion = SKEmitterNode(fileNamed: "Explosion")
            explosion?.position = firstNode.name == "alien" ? firstNode.position : secondNode.position
            self.addChild(explosion!)
            self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
            
            self.run(SKAction.wait(forDuration: 2)) {
                explosion?.removeFromParent()
            }
            
            if health == 0 {
                let explosion = SKEmitterNode(fileNamed: "Explosion")
                explosion?.position = firstNode.name == "player" ? firstNode.position : secondNode.position
                self.addChild(explosion!)
                self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
                
                self.run(SKAction.wait(forDuration: 2)) {
                    explosion?.removeFromParent()
                }
                firstNode.name == "player" ? firstNode.removeFromParent() : secondNode.removeFromParent()
                
                let userSettings = UserDefaults.standard
                userSettings.set(score, forKey: "lastScore")
                if score > userSettings.integer(forKey: "topScore") {
                    userSettings.set(score, forKey: "topScore")
                }
                
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let gameOver = GameOver(fileNamed: "GameOver")
                self.view?.presentScene(gameOver!, transition: transition)
            }

        }
        
    }

    @objc func addAliens() {
        let alien = SKSpriteNode(imageNamed: aliens.randomElement()!)
        let randomPos = GKRandomDistribution(lowestValue: 20, highestValue: Int(frame.width - 20))
        let pos = CGFloat(randomPos.nextInt())
        alien.name = "alien"
        alien.position = CGPoint(x: pos, y: frame.height + alien.size.height)
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = alien.physicsBody!.collisionBitMask
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        
        let animDuration: TimeInterval?
        
        animDuration = UserDefaults.standard.bool(forKey: "hard") ? 4 : 5
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: pos, y: 0 - alien.size.height), duration: animDuration!))
        actions.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actions))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fire()
    }
    
    func fire() {
        self.run(SKAction.playSoundFileNamed("bullet.mp3", waitForCompletion: false))
        
        let bullet = SKSpriteNode(imageNamed: "torpedo")
        bullet.name = "bullet"
        bullet.position = player.position
        bullet.position.y += 5
        
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        bullet.physicsBody?.isDynamic = true
        
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = alienCategory
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(bullet)
        
        let animDuration: TimeInterval = 0.5
        
        var actions = [SKAction]()
        actions.append(SKAction.move(to: CGPoint(x: player.position.x, y: frame.height + bullet.size.height), duration: animDuration))
        actions.append(SKAction.removeFromParent())
        
        bullet.run(SKAction.sequence(actions))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    override func didChangeSize(_ oldSize: CGSize) {
    }
}
