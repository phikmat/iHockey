//
//  GameScene.swift
//  iHockey P2P
//
//  Created by Mattia Picariello on 7/6/17.
//  Copyright © 2017 Mattia Picariello. All rights reserved.
//

import SpriteKit
import GameplayKit
import UIKit
import AVFoundation

let puckCategory: UInt32 = 0x1 << 0
let bottomCategory: UInt32 = 0x1 << 1
let topCategory: UInt32 = 0x1 << 2
let leftCategory: UInt32 = 0x1 << 3
let rightCategory: UInt32 = 0x1 << 4
let paddleCategory: UInt32 = 0x1 << 5
let leftGoalCategory: UInt32 = 0x1 << 6
let rightGoalCategory: UInt32 = 0x1 << 7
let borderCategory: UInt32 = 0x1 << 8


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var rightPaddle = SKSpriteNode()
    var leftPaddle = SKSpriteNode()
    var puck = SKSpriteNode()
    var rightGoal = SKSpriteNode()
    var leftGoal = SKSpriteNode()
    var leftScore = SKLabelNode()
    var rightScore = SKLabelNode()
    var leftScoreCounter = 0
    var rightScoreCounter = 0
    var winnerLabel = SKLabelNode()
    var didEnd = false
    var playAgainNode = SKSpriteNode()
    var resetNode = SKSpriteNode()
    var endedGame = false
    var bottom = SKSpriteNode()
    var top = SKSpriteNode()
    var left = SKSpriteNode()
    var right = SKSpriteNode()
    var bottomBorder = SKSpriteNode()
    var topBorder = SKSpriteNode()
    var myTurn = false
    var otherTurn = false
    
    func playMySound(){
        self.run(SKAction.playSoundFileNamed("mlg-airhorn", waitForCompletion: true))
    }
    func playEndSound(){
        self.run(SKAction.playSoundFileNamed("cheerSound", waitForCompletion: true))
    }
    
    override func didMove(to view: SKView)
    {
        //Instanzio i vari oggetti
        rightPaddle = self.childNode(withName: "rightPaddle") as! SKSpriteNode
        leftPaddle = self.childNode(withName: "leftPaddle") as! SKSpriteNode
        puck = self.childNode(withName: "puck") as! SKSpriteNode
        rightGoal = self.childNode(withName: "rightGoal") as! SKSpriteNode
        leftGoal = self.childNode(withName: "leftGoal") as! SKSpriteNode
        leftScore = self.childNode(withName: "leftScore") as! SKLabelNode
        rightScore = self.childNode(withName: "rightScore") as! SKLabelNode
        winnerLabel = self.childNode(withName: "winnerLabel") as! SKLabelNode
        playAgainNode = self.childNode(withName: "playAgain") as! SKSpriteNode
        bottomBorder = self.childNode(withName: "bottomRedLine") as! SKSpriteNode
        topBorder = self.childNode(withName: "topRedLine") as! SKSpriteNode
        resetNode = self.childNode(withName: "reset") as! SKSpriteNode
        
        playAgainNode.alpha = 0
        
        physicsWorld.contactDelegate = self
        
        //Costruisco i margini superiori ed inferiori
        let bottomLeft = CGPoint(x: frame.origin.x + 25, y: frame.origin.y)
        let bottomRight = CGPoint(x: -frame.origin.x - 25, y: frame.origin.y)
        let topLeft = CGPoint(x: frame.origin.x, y: 334)
        let topRight = CGPoint(x: -frame.origin.x, y: 334)
        bottom.name = "bottom"
        bottom.physicsBody = SKPhysicsBody(edgeFrom: bottomLeft, to: bottomRight)
        
        left.name = "left"
        left.physicsBody = SKPhysicsBody(edgeFrom: bottomLeft, to: topLeft)
        
        top.name = "top"
        top.physicsBody = SKPhysicsBody(edgeFrom: topLeft, to: topRight)
        
        right.name = "right"
        right.physicsBody = SKPhysicsBody(edgeFrom: topRight, to: bottomRight)
        
        addChild(bottom)
        addChild(top)
        
        topBorder.physicsBody?.categoryBitMask = borderCategory
        bottomBorder.physicsBody?.categoryBitMask = borderCategory
        leftPaddle.physicsBody?.categoryBitMask = paddleCategory
        rightPaddle.physicsBody?.categoryBitMask = paddleCategory
        puck.physicsBody?.categoryBitMask = puckCategory
        leftGoal.physicsBody?.categoryBitMask = leftGoalCategory
        rightGoal.physicsBody?.categoryBitMask = rightGoalCategory
        
        puck.physicsBody?.contactTestBitMask = paddleCategory | leftGoalCategory | rightGoalCategory
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches
        {
            let location = touch.location(in: self)
            if counter > 168 && endedGame == false {
                if location.x > 0 && location.y < 299 && location.x < -frame.origin.x - 25
                {
                    rightPaddle.run(SKAction.move(to: location, duration: 0.1))
                }
                else if location.x < 0 && location.y < 299 && location.x > frame.origin.x + 25
                {
                    leftPaddle.run(SKAction.move(to: location, duration: 0.1))
                }
            }
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches
        {
            let location = touch.location(in: self)
            if counter > 168 && endedGame == false {
                if location.x > 0 && location.y < 299 && location.x < -frame.origin.x - 25
                {
                    rightPaddle.run(SKAction.move(to: location, duration: 0.05))
                }
                else if location.x < 0 && location.y < 299 && location.x > frame.origin.x + 25
                {
                    leftPaddle.run(SKAction.move(to: location, duration: 0.05))
                }
            }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches
        {
            let location = touch.location(in: self)
            if counter > 168 && endedGame == true {
                if playAgainNode.contains(location) && playAgainNode.alpha == 1 {
                    reset()
                }
            }
            else if counter > 168 {
                if resetNode.contains(location) && resetNode.alpha == 1 {
                    reset()
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == paddleCategory
        {
            let currentPaddle = contact.bodyA.node?.name!
            
            if currentPaddle == "rightPaddle"
            {
                puck.physicsBody?.applyImpulse(CGVector(dx: 1.6 * (puck.position.x - rightPaddle.position.x), dy: 1.6 * (puck.position.y - rightPaddle.position.y)))
            }
            
            if currentPaddle == "leftPaddle"
            {
                let vector = CGVector(dx: 1.6 * (puck.position.x - leftPaddle.position.x), dy: 1.6 * (puck.position.y - leftPaddle.position.y))
                puck.physicsBody?.applyImpulse(vector)
                myTurn = true
                otherTurn = false
            }
        }
        
        if contact.bodyA.categoryBitMask == rightGoalCategory {
            if timerCounter > 0 && endedGame != true{
                leftScoreCounter += 1
                leftScore.text = "\(leftScoreCounter)"
                puck.run(SKAction.move(to: CGPoint(x: 150, y: 0), duration: 0.0))
                puck.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                playMySound()
                myTurn = false
                otherTurn = false
            }
            if leftScoreCounter >= 7 {
                winnerIs()
            }
        }
            
        else if contact.bodyA.categoryBitMask == leftGoalCategory {
            if timerCounter > 0  && endedGame != true{
                rightScoreCounter += 1
                rightScore.text = "\(rightScoreCounter)"
                puck.run(SKAction.move(to: CGPoint(x: -150, y: 0), duration: 0.0))
                puck.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                playMySound()
                myTurn = false
                otherTurn = false
            }
            if rightScoreCounter >= 7 {
                winnerIs()
            }
        }
    }
    
    func reset() {
        endedGame = false
        winnerLabel.isHidden = false
        self.winnerLabel.text = "Ready!"
        self.leftScore.text = "0"
        self.rightScore.text = "0"
        self.leftScoreCounter = 0
        self.rightScoreCounter = 0
        self.puck.run(SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0))
        self.rightPaddle.run(SKAction.move(to: CGPoint(x: 410, y: 0), duration: 0))
        self.leftPaddle.run(SKAction.move(to: CGPoint(x: -410, y: 0), duration: 0))
        self.puck.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.leftPaddle.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.rightPaddle.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        self.didEnd = false
        self.counter = 1
        self.timerCounter = 120
        self.playAgainNode.alpha = 0
        self.resetNode.alpha = 1
    }
    
    func winnerIs(){
        playAgainNode.alpha = 1
        resetNode.alpha = 0
        if rightScoreCounter > leftScoreCounter
        {
            winnerLabel.text = "Player 2 Wins!"
            didEnd = true
        }
        else if leftScoreCounter > rightScoreCounter
        {
            winnerLabel.text = "Player 1 Wins!"
            didEnd = true
        }
        else {
            didEnd = true
        }
        endedGame = true
        playEndSound()
    }
    
    var counter = 1
    var timerCounter = 120
    override func update(_ currentTime: TimeInterval) {
        if didEnd == false {
            counter += 1
        }
        if counter % 56 == 0 && timerCounter != 0
        {
            if counter <= 56 {
                winnerLabel.text = "Ready!"
            }
            else if counter <= 112 {
                winnerLabel.text = "Set!"
            }
            else if counter <= 168 {
                winnerLabel.text = "GO!"
            }
            else if counter > 168 {
                winnerLabel.isHidden = true
                timerCounter -= 1
                winnerLabel.text = "\(timerCounter)"
                if timerCounter <= 11 {
                    winnerLabel.isHidden = false
                }
            }
            
        }
        else if timerCounter == 0
        {
            playAgainNode.alpha = 1
            resetNode.alpha = 0
            if rightScoreCounter > leftScoreCounter
            {
                winnerLabel.text = "Player 2 Wins!"
                playEndSound()
                endedGame = true
                didEnd = true
            }
            else if leftScoreCounter > rightScoreCounter
            {
                winnerLabel.text = "Player 1 Wins!"
                playEndSound()
                endedGame = true
                didEnd = true
            }
            else {
                didEnd = true
                endedGame = true
            }
        }
        if rightPaddle.position.x < 0 {
            rightPaddle.position = CGPoint(x: 0, y: rightPaddle.position.y)
        }
        if leftPaddle.position.x > 0 {
            leftPaddle.position = CGPoint(x: 0, y: leftPaddle.position.y)
        }
    }
}

