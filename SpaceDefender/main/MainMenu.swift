//
//  MainMenu.swift
//  SpaceDefender
//
//  Created by MacBookPro on 17/10/2018.
//  Copyright © 2018 MacBookPro. All rights reserved.
//

import SpriteKit

class MainMenu: SKScene {
    
    var starfield: SKEmitterNode!
    var newGameButton: SKSpriteNode!
    var levelButton: SKSpriteNode!
    var labelLevel: SKLabelNode!
    var labelScore: SKLabelNode!
    var labelMain: SKLabelNode!
    
    override func didMove(to view: SKView) {
        starfield = SKEmitterNode(fileNamed: "Starfield.sks")
        starfield.position = CGPoint(x: 0, y: frame.maxY)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        
        starfield.zPosition = -1
        
        newGameButton = SKSpriteNode(color: UIColor.black, size: CGSize(width: frame.width*0.6, height: frame.height*0.1))
        newGameButton.position = CGPoint(x: frame.midX, y: frame.midY+frame.maxY*0.07)
        newGameButton.alpha = 0.2
        newGameButton.zPosition = 1
        self.addChild(newGameButton)
        
        let labelNewGameButton = SKLabelNode(text: "New Game")
        labelNewGameButton.position = CGPoint(x: frame.midX, y: frame.midY+frame.maxY*0.07)
        labelNewGameButton.zPosition = 0
        self.addChild(labelNewGameButton)
        
        levelButton = SKSpriteNode(color: UIColor.black, size: CGSize(width: frame.width*0.6, height: frame.height*0.1))
        levelButton.position = CGPoint(x: frame.midX, y: frame.midY-frame.maxY*0.07)
        levelButton.name = "levelButton"
        levelButton.alpha = 0.2
        levelButton.zPosition = 1
        self.addChild(levelButton)
        
        let labelLevelButton = SKLabelNode(text: "Level")
        labelLevelButton.position = CGPoint(x: frame.midX, y: frame.midY-frame.maxY*0.07)
        labelLevelButton.zPosition = 0
        self.addChild(labelLevelButton)
        
        labelMain = SKLabelNode(text: "Space Defender")
        labelMain.fontSize = 40
        labelMain.position = CGPoint(x: frame.midX, y: frame.maxY*0.85)
        self.addChild(labelMain)
        
        labelScore = SKLabelNode()
        labelScore.text = "Top Score: \(UserDefaults.standard.integer(forKey: "topScore"))"
        labelScore.position = CGPoint(x: frame.midX, y: frame.maxY*0.25)
        self.addChild(labelScore)

        labelLevel = SKLabelNode()
        labelLevel.fontSize = 30
        labelLevel.position = CGPoint(x: frame.midX, y: frame.maxY*0.15)
        self.addChild(labelLevel)
        
        if UserDefaults.standard.bool(forKey: "hard") {
            labelLevel.text = "Hard"
        } else {
            labelLevel.text = "Easy"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first == newGameButton {
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let gameScene = GameScene(size: UIScreen.main.bounds.size)
                self.view?.presentScene(gameScene, transition: transition)
            } else if nodesArray.first?.name == "levelButton" {
                changeLevel()
            }
        }
    }
    
    func changeLevel() {
        let userSettings = UserDefaults.standard
        
        if labelLevel.text == "Easy" {
            labelLevel.text = "Hard"
            userSettings.set(true, forKey: "hard")
        } else {
            labelLevel.text = "Easy"
            userSettings.set(false, forKey: "hard")
        }
        
    }
}
