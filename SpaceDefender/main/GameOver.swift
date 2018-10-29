//
//  GameOver.swift
//  SpaceDefender
//
//  Created by MacBookPro on 20/10/2018.
//  Copyright © 2018 MacBookPro. All rights reserved.
//

import SpriteKit

class GameOver: SKScene {
    
    var starfield: SKEmitterNode!
    var mainMenuButton: SKSpriteNode!
    var labelScore: SKLabelNode!
    var labelGameOver: SKLabelNode!
    
    override func didMove(to view: SKView) {
        starfield = SKEmitterNode(fileNamed: "Starfield.sks")
        starfield.position = CGPoint(x: 0, y: frame.maxY)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        
        starfield.zPosition = -1
        
        mainMenuButton = SKSpriteNode(color: UIColor.black, size: CGSize(width: frame.width*0.6, height: frame.height*0.1))
        mainMenuButton.position = CGPoint(x: frame.midX, y: frame.midY+frame.maxY*0.07)
        mainMenuButton.name = "mainMenuButton"
        mainMenuButton.alpha = 0.2
        mainMenuButton.zPosition = 1
        self.addChild(mainMenuButton)
        
        let labelMainMenuButton = SKLabelNode(text: "Main Menu")
        labelMainMenuButton.position = CGPoint(x: frame.midX, y: frame.midY+frame.maxY*0.07)
        labelMainMenuButton.zPosition = 0
        self.addChild(labelMainMenuButton)
        
        labelGameOver = SKLabelNode(text: "Game Over")
        labelGameOver.fontSize = 40
        labelGameOver.position = CGPoint(x: frame.midX, y: frame.maxY*0.85)
        self.addChild(labelGameOver)
        
        labelScore = SKLabelNode()
        labelScore.text = "Score: \(UserDefaults.standard.integer(forKey: "lastScore"))"
        labelScore.fontSize = 30
        labelScore.position = CGPoint(x: frame.midX, y: frame.maxY*0.25)
        self.addChild(labelScore)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "mainMenuButton" {
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let mainMenu = MainMenu(fileNamed: "MainMenu")
                self.view?.presentScene(mainMenu!, transition: transition)
            }
        }
    }
    
    
    
}
