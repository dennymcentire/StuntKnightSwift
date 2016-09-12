//
//  Player.swift
//  StuntKnightSwift
//
//  Created by Denny McEntire on 9/3/16.
//  Copyright © 2016 Denny McEntire. All rights reserved.
//

import SpriteKit


class Player: SKSpriteNode {
    
    var health = 50;
    
    let atlas:SKTextureAtlas = SKTextureAtlas(named: "stuntKnight")
    
    func isRotating() -> Bool {
        let curVel: CGFloat = (physicsBody?.angularVelocity)!
        //NSLog("Body Angular Velocity: %f", curVel);
        if(curVel > 3 || curVel < -3) {
            return true;
        }
        return false;
    }
    
    func isDead() -> Bool {
        //NSLog("isDead: %i", health);
        if(health > 0) {
            return false;
        } else {
            return true;
        }
    }
    
    func stand() {
        if (self.actionForKey("standingStuntKnight") == nil) {
            removeAllActions()
            var frames = [SKTexture]()
            
            let numImages = 6
            for var i=1; i<=numImages; i++ {
                let textureName = "stuntKnightStand\(i)"
                frames.append(atlas.textureNamed(textureName))
            }
            
            //standFrames = frames
            
            let firstFrame = frames[0]
            self.texture = firstFrame
            self.runAction(SKAction.repeatActionForever(
                SKAction.animateWithTextures(frames,
                    timePerFrame: 0.2,
                    resize: true,
                    restore: true)),
                withKey:"standingStuntKnight")
        }
    }
    
    func walk() {
        if (self.actionForKey("walkingStuntKnight") == nil) {
            removeAllActions()
            var frames = [SKTexture]()
            
            let numImages = 14
            for var i=1; i<=numImages; i++ {
                let textureName = "stuntKnightWalk\(i)"
                frames.append(atlas.textureNamed(textureName))
            }
            
            //standFrames = frames
            
            let firstFrame = frames[0]
            self.texture = firstFrame
            self.runAction(SKAction.repeatActionForever(
                SKAction.animateWithTextures(frames,
                    timePerFrame: 0.08,
                    resize: true,
                    restore: true)),
                withKey:"walkingStuntKnight")
        }
    }
    
    func turnLeft() {
        physicsBody?.applyTorque(2)
        spin()
    }
    
    func turnRight() {
        physicsBody?.applyTorque(-2)
        spin()
    }
    
    func spin() {
        if (self.actionForKey("spinningStuntKnight") == nil) {
            removeAllActions()
            var frames = [SKTexture]()
            
            let numImages = 1
            for var i=1; i<=numImages; i++ {
                let textureName = "stuntKnightSpin\(i)"
                frames.append(atlas.textureNamed(textureName))
            }
            
            let firstFrame = frames[0]
            self.texture = firstFrame
            //self.size = firstFrame.size();
            self.runAction(SKAction.repeatActionForever(
                SKAction.animateWithTextures(frames,
                    timePerFrame: 0.1,
                    resize: true,
                    restore: true)),
                withKey:"spinningStuntKnight")
        }
    }
    
    func damage(damageCount: Int) {
        //NSLog("Player:damage");
        let force: CGVector = CGVector(dx: 0, dy: 1.8);
        physicsBody?.applyForce(force);
        if(health > 0) {
            health = health - damageCount;
        }
    }
    
    func setHorizontalVelocity(direction: SwipeStates) {
        //NSLog(@"_scratchState: %@", _scratchState);
        var vel:CGVector = (physicsBody?.velocity)!
        var xVel: CGFloat = 0
        if(direction == .Still) {
            xVel = 0
        } else if(direction == .Right) {
            xVel = 1
        } else if(direction == .Left) {
            xVel = -1
        } else {
            xVel = vel.dx
        }
        
        if(xVel > 0) {
            vel.dx = 100
            self.xScale = -abs(self.xScale);
        } else if (xVel < 0) {
            vel.dx = -100
            self.xScale = abs(self.xScale);
        } else {
            vel.dx = 0
        }
        physicsBody?.velocity = vel
    }
    
    func limitVerticalVelocity() {
        var vel:CGVector = (physicsBody?.velocity)!
        if(vel.dy > 200) {
            vel.dy = 200
        }
    }
    
    func update(direction: SwipeStates) {
        setHorizontalVelocity(direction)
        limitVerticalVelocity()
        
        if(!isRotating()) {
            zRotation = 0
            walk()
        } else {
            spin()
        }
    }
    
}