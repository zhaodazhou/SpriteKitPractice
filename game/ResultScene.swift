//
//  ResultScene.swift
//  game
//
//  Created by dazhou on 2017/7/2.
//  Copyright © 2017年 dazhou. All rights reserved.
//

import UIKit
import SpriteKit

class ResultScene: SKScene {
    
//    var resultScene : ResultScene!
    
    
    open func setWon(_ won : Bool) {
        
        self.backgroundColor = SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        //1 Add a result label to the middle of screen
        let resultLabel = SKLabelNode(fontNamed: "Chalkduster")
        resultLabel.text = won ? "You win!" : "You lose"
        resultLabel.fontSize = 30
        resultLabel.fontColor = SKColor.black
        resultLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(resultLabel)
        
        //2 Add a retry label below the result label
        let retryLabel = SKLabelNode(fontNamed: "Chalkduster")
        retryLabel.text = "Try again"
        retryLabel.fontSize = 20
        retryLabel.fontColor = SKColor.blue
        retryLabel.position = CGPoint(x: resultLabel.position.x, y: resultLabel.position.y * 0.8)
        retryLabel.name = "retryLabel"
        self.addChild(retryLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            let node = self.atPoint(touchLocation)
            
            if node.name == "retryLabel" {
                changeToGameScene()
            }
        }
    }
    
    func changeToGameScene() {
        let ms = MyScene(size: self.size)
        let reveal = SKTransition.reveal(with: .down, duration: 1.0)
        self.scene?.view?.presentScene(ms, transition: reveal)
    }

}
