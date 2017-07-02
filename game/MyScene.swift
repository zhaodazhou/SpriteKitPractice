//
//  MyScene.swift
//  game
//
//  Created by dazhou on 2017/6/27.
//  Copyright © 2017年 dazhou. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation

class MyScene: SKScene {
    
    var monsters : NSMutableArray!
    var projectiles : NSMutableArray!
    
    var bgmPlayer : AVAudioPlayer!
    
    var projectileSoundEffectAction : SKAction?
    var monstersDestroyed = 0
    
    override init(size: CGSize) {
        super.init(size: size)
        
//        /* Setup your scene here */
        let bgmPath = Bundle.main.path(forResource: "background-music-aac", ofType: "caf")
        let url = URL(fileURLWithPath: bgmPath!)
        do {
            bgmPlayer = try AVAudioPlayer(contentsOf: url)
        } catch {}
        
        bgmPlayer.numberOfLoops = -1;
        bgmPlayer.play()
        
        self.projectileSoundEffectAction = SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false)
        self.monsters = NSMutableArray()
        self.projectiles = NSMutableArray()
        
        
        self.backgroundColor = SKColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        let player = SKSpriteNode(imageNamed: "player")
        
        player.position = CGPoint(x: player.size.width / 2, y: size.height / 2)
        
        addChild(player)
        
        let actionAddMonster = SKAction.run { 
            self.addMonster()
        }
        let actionWaitNextMonster = SKAction.wait(forDuration: 1)
        run(SKAction.repeatForever(SKAction.sequence([actionAddMonster, actionWaitNextMonster])))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addMonster() {
        
        let monster = SKSpriteNode(imageNamed: "monster")
        
        //1 Determine where to spawn the monster along the Y axis
        let winSize = self.size
        let minY : Int = (Int)(monster.size.height) / 2
        let maxY : Int = (Int)(winSize.height - monster.size.height) / 2
        
        let rangeY : Int = Int(maxY - minY)
        var random : Int = Int(arc4random())
        let actualY = (random % rangeY) + minY
        
        //2 Create the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        let cgfloatY : CGFloat = CGFloat(actualY)
        monster.position = CGPoint(x: winSize.width + monster.size.width / 2, y: cgfloatY)
        addChild(monster)
        
        //3 Determine speed of the monster
        let minDuration = 2
        let maxDuration = 4
        let rangeDuration = maxDuration - minDuration
        random = Int(arc4random())
        let actualDuration = random % rangeDuration + minDuration
        
        
        //4 Create the actions. Move monster sprite across the screen and remove it from scene after finished.
        let movetoPoint = CGPoint(x : -monster.size.width / 2, y : (CGFloat)(actualY))
        let actionMove = SKAction.move(to: movetoPoint, duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.run { 
            monster .removeFromParent()
            self.monsters?.remove(monster)
            self.changeToResultSceneWithWon(false)
        }
        
        let actionArr = [actionMove, actionMoveDone]
        monster.run(SKAction.sequence(actionArr))
        
        monsters?.add(monster)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            //1 Set up initial location of projectile
            let winSize = size
            let projectile = SKSpriteNode(imageNamed: "projectile.png")
            projectile.position = CGPoint(x: projectile.size.width / 2, y: winSize.height / 2)
            
            //2 Get the touch location tn the scene and calculate offset
            let location = touch.location(in: self)
            let offset = CGPoint(x: location.x - projectile.position.x, y: location.y - projectile.position.y)
            
            // Bail out if you are shooting down or backwards
            if offset.x <= 0 {
                return
            }
            // Ok to add now - we've double checked position
            addChild(projectile)
            
            let realX = winSize.width + (projectile.size.width / 2)
            let ratio = offset.y / offset.x
            let realY = (realX * ratio) + projectile.position.y
            let realDest = CGPoint(x: realX, y: realY)
            
            //3 Determine the length of how far you're shooting
            let offRealX = realX - projectile.position.x
            let offRealY = realY - projectile.position.y
            let length = sqrtf(Float((offRealX * offRealX) + (offRealY * offRealY)))
            let velocity = self.size.width / 1
            let realMoveDuration = (CGFloat)(length) / velocity
            
            //4 Move projectile to actual endpoint and play the throw sound effect
            let moveAction = SKAction.move(to: realDest, duration: TimeInterval(realMoveDuration))
            let projectileCastAction = SKAction.group([moveAction, self.projectileSoundEffectAction!])
            projectile.run(projectileCastAction, completion: { 
                projectile.removeFromParent()
                self.projectiles.remove(projectile)
            })
            
            projectiles.add(projectile)
            
        }
        
        
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
        let projectilesToDelete = NSMutableArray()
        for projectile in self.projectiles {
            let monstersToDelete = NSMutableArray()
            for monster in self.monsters {
                if (projectile as! SKSpriteNode).frame.intersects((monster as! SKSpriteNode).frame) {
                    monstersToDelete.add(monster)
                }
            }
            
            for monster in monstersToDelete {
                self.monsters.remove(monster)
                (monster as AnyObject).removeFromParent()
                
                self.monstersDestroyed = self.monstersDestroyed + 1
                if self.monstersDestroyed >= 10 {
                    changeToResultSceneWithWon(true)
                }
            }
            
           
            
            if (monstersToDelete.count) > 0 {
                projectilesToDelete.add(projectile)
            }
        }
        

        for projectile in projectilesToDelete {
            self.projectiles.remove(projectile);
            (projectile as? SKSpriteNode)?.removeFromParent()
        }
    }
    
    func changeToResultSceneWithWon(_ won : Bool) {
        bgmPlayer.stop()
        bgmPlayer = nil
        
        let rs = ResultScene(size: self.size)
        rs.setWon(won)
        let reveal = SKTransition.reveal(with: .up, duration: 1.0)
        self.scene?.view?.presentScene(rs, transition: reveal)
    }

}



























