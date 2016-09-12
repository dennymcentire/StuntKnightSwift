//
//  MenuScene.swift
//  Fear The Dead
//
//  Created by Morten Faarkrog on 12/09/15.
//  Copyright © 2015 Razeware. All rights reserved.
//

import UIKit
import SpriteKit

class MenuScene: SKScene {
    
    var soundToPlay: String?
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor(red: 0, green:0, blue:0, alpha: 1)
        
        // Setup label
        let label = SKLabelNode(text: "Press anywhere to play again!")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 120
        label.fontColor = UIColor.whiteColor()
        label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
        
        self.addChild(label)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let gameScene = GameScene(fileNamed: "GameScene")
        let transition = SKTransition.flipVerticalWithDuration(1.0)
        let skView = self.view as SKView!
        gameScene?.scaleMode = .AspectFill
        skView.presentScene(gameScene!, transition: transition)
    }
    
}
