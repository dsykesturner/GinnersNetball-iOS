//
//  GameScene.swift
//  TheGinnersGame
//
//  Created by Daniel Sykes-Turner on 15/7/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import SpriteKit
import GameplayKit

struct pc { // Physics Category
    static let none: UInt32 = 0x1 << 0
    static let ball: UInt32 = 0x1 << 1
    static let blockEdge: UInt32 = 0x1 << 2
    static let blockBottom: UInt32 = 0x1 << 3
}

struct blockSizes {
    static let bottomBlockHeight:CGFloat = 30
    static let bottomBlockWidth:CGFloat = 100
    static let edgeBlockHeight:CGFloat = 150
    static let edgeBlockWidth:CGFloat = 30
}

struct ballSizes {
    static let ballWidth:CGFloat = 50
}

class GameScene: SKScene {
    
    var scoreNode : SKLabelNode?
    var blockNode: SKShapeNode?
    var blockNodeL: SKShapeNode?
    var blockNodeR: SKShapeNode?
    
    var score: Int = 0
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.setupBlockNode()
        self.setupScoreNode()
        self.startSpawningBalls()
    }
    
    func setupScoreNode() {
        // Add the current score
        let x = self.size.width / 2
        let y = self.size.height * 0.8
        self.scoreNode = SKLabelNode(text: "0")
        self.scoreNode?.alpha = 0.0
        self.scoreNode?.numberOfLines = 0
        self.scoreNode?.horizontalAlignmentMode = .center // why isnt this working
        self.scoreNode?.position = CGPoint(x: x, y: y)
        self.scoreNode?.run(SKAction.fadeIn(withDuration: 2.0))
        self.addChild(self.scoreNode!)
    }
    
    func setupBlockNode() {
        // Build the bottom block
        let bottomBlockWidth = blockSizes.bottomBlockWidth
        let bottomBlockHeight = blockSizes.bottomBlockHeight
        var size = CGSize(width: bottomBlockWidth, height: bottomBlockHeight)
        let bottomBlockX = self.size.width/2
        let bottomBlockY = CGFloat(40)
        self.blockNode = SKShapeNode(rectOf: size)
        self.blockNode?.lineWidth = 2.5
        self.blockNode?.position = CGPoint(x: bottomBlockX, y: bottomBlockY)
        self.blockNode?.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.blockNode?.physicsBody?.isDynamic = false
        self.blockNode?.physicsBody?.categoryBitMask = pc.blockBottom
        self.blockNode?.physicsBody?.collisionBitMask = pc.none
        self.blockNode?.physicsBody?.contactTestBitMask = pc.none
        
        // Build the left block
        let edgeBlockHeight = blockSizes.edgeBlockHeight
        let edgeBlockWidth = blockSizes.edgeBlockWidth
        size = CGSize(width: edgeBlockWidth, height: edgeBlockHeight)
        var edgeBlockX = bottomBlockX - bottomBlockWidth/2 - edgeBlockWidth/2
        let edgeBlockY = bottomBlockY - bottomBlockHeight/2 + edgeBlockHeight/2
        self.blockNodeL = SKShapeNode(rectOf: size)
        self.blockNodeL?.lineWidth = 2.5
        self.blockNodeL?.position = CGPoint(x: edgeBlockX, y: edgeBlockY)
        self.blockNodeL?.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.blockNodeL?.physicsBody?.isDynamic = false
        self.blockNodeL?.physicsBody?.categoryBitMask = pc.blockEdge
        self.blockNodeL?.physicsBody?.collisionBitMask = pc.ball
        
        edgeBlockX = bottomBlockX + bottomBlockWidth/2 + edgeBlockWidth/2
        self.blockNodeR = SKShapeNode(rectOf: size)
        self.blockNodeR?.lineWidth = 2.5
        self.blockNodeR?.position = CGPoint(x: edgeBlockX, y: edgeBlockY)
        self.blockNodeR?.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.blockNodeR?.physicsBody?.isDynamic = false
        self.blockNodeR?.physicsBody?.categoryBitMask = pc.blockEdge
        self.blockNodeR?.physicsBody?.collisionBitMask = pc.ball
        
        addChild(self.blockNode!)
        addChild(self.blockNodeL!)
        addChild(self.blockNodeR!)
    }
    
    func startSpawningBalls() {
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run(spawnBall),
            SKAction.wait(forDuration: 0.4)
            ])
        ))
    }
    
    func moveBlock(toPosition pos: CGPoint) {
        if let bottom = self.blockNode,
            let left = self.blockNodeL,
            let right = self.blockNodeR {
            
            let currentX = bottom.position.x
            let diff = currentX-pos.x
            var newX = pos.x
            if diff >= ballSizes.ballWidth/2 {
                print("moving too far! \(diff). limiting dist")
                newX = currentX - ballSizes.ballWidth/2 - 0.1
            } else if diff <= -ballSizes.ballWidth/2 {
                newX = currentX + ballSizes.ballWidth/2 - 0.1
            }
            
            bottom.position = CGPoint(x: newX, y: bottom.position.y)
            
            var x = newX - blockSizes.bottomBlockWidth/2 - blockSizes.edgeBlockWidth/2
            let y = bottom.position.y - blockSizes.bottomBlockHeight/2 + blockSizes.edgeBlockHeight/2
            left.position = CGPoint(x: x, y: y)
            
            x = newX + blockSizes.bottomBlockWidth/2 + blockSizes.edgeBlockWidth/2
            right.position = CGPoint(x: x, y: y)
        }
    }
    
    func updateScore() {
        self.scoreNode?.text = "\(self.score)"
    }
    
    func spawnBall() {
        let w = ballSizes.ballWidth
        let x = CGFloat(arc4random() % UInt32(self.size.width))
        let y = self.size.height
        
        let netballNumber = arc4random() % 5 + 1
        let netballImage = "netball\(netballNumber)"
        let ball = SKSpriteNode(imageNamed: netballImage)
        ball.position = CGPoint(x: x, y: y)
        ball.size = CGSize(width: w, height: w)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: w/2)
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.categoryBitMask = pc.ball
        ball.physicsBody?.collisionBitMask = (pc.blockEdge | pc.blockBottom | pc.ball)
        ball.physicsBody?.contactTestBitMask = pc.blockBottom
        
        // Vanish after 20 seconds
        ball.run(SKAction.sequence([
            SKAction.wait(forDuration: 60),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
        
        self.addChild(ball)
    }
}

// MARK: Touch Guestures

extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.moveBlock(toPosition: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.moveBlock(toPosition: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}

// MARK: SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        
        self.score += 1
        self.updateScore()
        
        if contact.bodyA.categoryBitMask == pc.ball,
            let node = contact.bodyA.node {
            // Don't allow this ball to call this again
            node.physicsBody?.contactTestBitMask = pc.none
            node.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.removeFromParent()
            ]))
        } else if let node = contact.bodyB.node {
            // Don't allow this ball to call this again
            node.physicsBody?.contactTestBitMask = pc.none
            node.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.removeFromParent()
            ]))
        }
    }
}
