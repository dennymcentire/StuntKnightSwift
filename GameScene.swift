//
//  GameScene.swift
//  StuntKnightSwift
//
//  Created by Denny McEntire on 9/2/16.
//  Copyright (c) 2016 Denny McEntire. All rights reserved.
//

import SpriteKit

enum SwipeStates: Int {
    case Still = 0
    case Right = 1
    case Left = 2
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //var player: SKSpriteNode?
    var player: Player!
    var deathGels: [SKSpriteNode] = []
    var deathWalkingFrames : [SKTexture]!
    var endOfLevel: SKSpriteNode? = nil
    
    var lastTouch: CGPoint? = nil
    var swipeState: SwipeStates = .Still
    
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.clearColor() //SKColor(red: 0, green:0, blue:0, alpha: 1)
        
        // Setup physics world's contact delegate
        //physicsWorld.gravity = CGVectorMake(0.0,-1.0)
        physicsWorld.contactDelegate = self
        
        // Setup player
        player = self.childNodeWithName("player") as! Player
        player!.physicsBody?.usesPreciseCollisionDetection = true
        player.stand()
        print("Player Health: \(player.health)")
        
        self.listener = player
        
        // Setup zombies
        for child in self.children {
            if child.name == "stompy" {
                if let child = child as? SKSpriteNode {
                    // Add SKAudioNode to zombie
                    deathGels.append(child)
                    setUpDeathGel(child)
                }
            }
        }
        
        endOfLevel = (self.childNodeWithName("end-of-level") as! SKSpriteNode)
        
        updateCamera()
    }

    override func didSimulatePhysics() {
        if let _ = player {
            updateCamera()
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        // Start the player by putting them into the physics simulation
        player!.physicsBody?.dynamic = true
        
        // 4
        player!.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 200.0))
        
        for touch in touches {
            let touchLocation = touch.locationInNode(self)
            lastTouch = touchLocation
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
        let touchLocation = touches.first!.locationInNode(self)
        
        if(lastTouchLocationExists()) {
            //NSLog(@"setting scratch state");
            setSwipeState(touchLocation);
        }
    
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touchLocation = touches.first!.locationInNode(self)
        
        if(lastTouchLocationExists()) {
            //NSLog(@"setting scratch state");
            setSwipeState(touchLocation);
        }
        
        clearTouchLocation()
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        //updateCamera()
        player.update(swipeState);
        
        if(player.isDead()) {
            NSLog("player died")
            gameOver(false)
        }
    }
    
    func setUpDeathGel(thisDeath: SKSpriteNode) {
        let deathGelAtlas = SKTextureAtlas(named: "deathGel")
        var walkFrames = [SKTexture]()
        
        let numImages = 3
        for var i=1; i<=numImages; i++ {
            let deathTextureName = "deathGel\(i)"
            walkFrames.append(deathGelAtlas.textureNamed(deathTextureName))
        }
        
        deathWalkingFrames = walkFrames
        
        let firstFrame = deathWalkingFrames[0]
        thisDeath.texture = firstFrame
        thisDeath.runAction(SKAction.repeatActionForever(
            SKAction.animateWithTextures(deathWalkingFrames,
                timePerFrame: 0.2,
                resize: false,
                restore: true)),
            withKey:"walkingInPlaceDeath")
    }
    
    func updateCamera() {
        if let camera = camera {
            camera.position = CGPoint(x: player!.position.x, y: camera.position.y)
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        // 1. Create local variables for two physics bodies
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        // 2. Assign the two physics bodies so that the one with the lower category is always stored in firstBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 3. react to the contact between the two nodes
        if firstBody.categoryBitMask == player?.physicsBody?.categoryBitMask {
            if secondBody.categoryBitMask == deathGels[0].physicsBody?.categoryBitMask {
                // Player & Stompy
                playerHitStompy(secondBody.node!)
                //gameOver(false)
            } else if secondBody.categoryBitMask == endOfLevel!.physicsBody?.categoryBitMask {
                gameOver(true)
            }
        }
    }
    
    func playerHitStompy(stompy: SKNode) {
        if(player.isRotating()) {
            killStompy(stompy)
        } else {
            hurtPlayer()
        }
    }
    
    func killStompy(stompy: SKNode) {
        let thisDeath: SKSpriteNode = (stompy as? SKSpriteNode)!;
        let deathGelAtlas = SKTextureAtlas(named: "deathGel")
        var walkFrames = [SKTexture]()
        
        let numImages = 15
        for var i=1; i<=numImages; i++ {
            let deathTextureName = "deathGelHit\(i)"
            walkFrames.append(deathGelAtlas.textureNamed(deathTextureName))
        }
        
        deathWalkingFrames = walkFrames
        
        let firstFrame = deathWalkingFrames[0]
        thisDeath.texture = firstFrame
        thisDeath.runAction(SKAction.repeatAction(
            SKAction.animateWithTextures(deathWalkingFrames,
                timePerFrame: 0.1,
                resize: false,
                restore: true), count: 1), completion: {() -> Void in
                    stompy.removeFromParent()
        })
        
        //thisDeath.physicsBody?.categoryBitMask = 0
        //deathGels = deathGels.filter() {$0 != thisDeath}
        //thisDeath.physicsBody?.categoryBitMask = 0
    }
    
    func hurtPlayer() {
        player.damage(1);
    }
    
    func lastTouchLocationExists() -> Bool {
        return lastTouch!.x > 0;
    }
    
    func clearTouchLocation() {
        lastTouch!.x = -1
    }
    
    func setSwipeState(touchLocation: CGPoint) {
        let sensitivity: CGFloat = 20;
        let xDist: CGFloat = touchLocation.x - lastTouch!.x;
        if(xDist < sensitivity && xDist > -sensitivity) {
            swipeState = .Still;
        } else if (xDist > sensitivity) {
            swipeState = .Right;
            player.turnRight()
        } else if (xDist < -sensitivity) {
            swipeState = .Left;
            player.turnLeft()
        } else {
            player.turnRight()
        }
    }
    
    
    private func gameOver(didWin: Bool) {
        print("- - - Game Ended - - -")
        let menuScene = MenuScene(size: self.size)
        let transition = SKTransition.flipVerticalWithDuration(1.0)
        menuScene.scaleMode = SKSceneScaleMode.AspectFill
        self.scene!.view?.presentScene(menuScene, transition: transition)
    }

}
