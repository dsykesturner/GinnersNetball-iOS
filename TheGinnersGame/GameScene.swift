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
    static let boundary: UInt32 = 0x1 << 4
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

enum GameDifficulty: Double {
    case easy = 1.1
    case hard = 1.25
    
    func toString() -> String {
        switch self {
        case .easy:
            return "Easy"
        case .hard:
            return "Hard"
        }
    }
}

enum GameState {
    case intro
    case started
    case ended
}

protocol GameSceneDelegate:class {
    func quitGame()
    func saveNewScore(_ score: Int, difficulty: GameDifficulty)
}

class GameScene: SKScene {
    
    var scoreNode: SKLabelNode!
    var levelNode: SKLabelNode!
    var gameStateNode: SKLabelNode!
    var boundaryNode: SKShapeNode!
    var blockNode: SKShapeNode!
    var blockNodeL: SKShapeNode!
    var blockNodeR: SKShapeNode!
    var ballNodes: [SKSpriteNode] = []
    var playAgainButton: SKLabelNode!
    var quitButton: SKLabelNode!
    
    weak var gameDelegate: GameSceneDelegate!
    
    var state: GameState = .started
    var difficulty: GameDifficulty = .easy
    var level: Int = 1
    var score: Int = 0 {
        didSet {
            self.scoreNode?.text = "\(self.score)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.setupNodes()
        
        // Start with the game intro
        self.showGameIntro()
    }
    
    func setupNodes() {
        self.setupScoreNode()
        self.setupLevelNode()
        self.setupGameStateNodes()
        self.setupBlockNode()
        self.setupBoundaryNode()
    }
    
    func setupScoreNode() {
        // Add the current score
        let x = self.size.width / 2
        let y = self.size.height * 0.8
        self.scoreNode = SKLabelNode(text: "0")
        self.scoreNode.alpha = 0.0
        self.scoreNode.numberOfLines = 0
        self.scoreNode.position = CGPoint(x: x, y: y)
        self.addChild(self.scoreNode!)
    }
    
    func setupLevelNode() {
        let x = self.size.width / 2
        let y = self.scoreNode.position.y + self.scoreNode.frame.height + 10
        
        self.levelNode = SKLabelNode()
        self.levelNode.alpha = 0.0
        self.levelNode.position = CGPoint(x: x, y: y)
        
        self.addChild(self.levelNode)
    }
    
    func setupGameStateNodes() {
        let x = self.size.width * 0.5
        let gameStateY = self.size.height * 0.6

        self.gameStateNode = SKLabelNode()
        self.gameStateNode.position = CGPoint(x: x, y: gameStateY)
        
        self.addChild(self.gameStateNode)
        
        let playAgainY = self.size.height * 0.4
        
        self.playAgainButton = SKLabelNode(text: "Play Again")
        self.playAgainButton.position = CGPoint(x: x, y: playAgainY)
        self.playAgainButton.alpha = 0
        
        self.addChild(playAgainButton)
        
        let quitY = self.playAgainButton.position.y - self.playAgainButton.frame.height - 20
        
        self.quitButton = SKLabelNode(text: "Quit")
        self.quitButton.position = CGPoint(x: x, y: quitY)
        self.quitButton.alpha = 0
        
        self.addChild(quitButton)
    }
    
    func setupBlockNode() {
        // Build the bottom block
        let bottomBlockWidth = blockSizes.bottomBlockWidth
        let bottomBlockHeight = blockSizes.bottomBlockHeight
        var size = CGSize(width: bottomBlockWidth, height: bottomBlockHeight)
        let bottomBlockX = self.size.width/2
        let bottomBlockY = CGFloat(60)
        self.blockNode = SKShapeNode(rectOf: size)
        self.blockNode.lineWidth = 2.5
        self.blockNode.alpha = 0
        self.blockNode.position = CGPoint(x: bottomBlockX, y: bottomBlockY)
        self.blockNode.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.blockNode.physicsBody?.isDynamic = false
        self.blockNode.physicsBody?.categoryBitMask = pc.blockBottom
        self.blockNode.physicsBody?.collisionBitMask = pc.none
        self.blockNode.physicsBody?.contactTestBitMask = pc.none
        
        // Build the left block
        let edgeBlockHeight = blockSizes.edgeBlockHeight
        let edgeBlockWidth = blockSizes.edgeBlockWidth
        size = CGSize(width: edgeBlockWidth, height: edgeBlockHeight)
        var edgeBlockX = bottomBlockX - bottomBlockWidth/2 - edgeBlockWidth/2
        let edgeBlockY = bottomBlockY - bottomBlockHeight/2 + edgeBlockHeight/2
        self.blockNodeL = SKShapeNode(rectOf: size)
        self.blockNodeL.lineWidth = 2.5
        self.blockNodeL.alpha = 0
        self.blockNodeL.position = CGPoint(x: edgeBlockX, y: edgeBlockY)
        self.blockNodeL.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.blockNodeL.physicsBody?.isDynamic = false
        self.blockNodeL.physicsBody?.categoryBitMask = pc.blockEdge
        self.blockNodeL.physicsBody?.collisionBitMask = pc.ball
        
        edgeBlockX = bottomBlockX + bottomBlockWidth/2 + edgeBlockWidth/2
        self.blockNodeR = SKShapeNode(rectOf: size)
        self.blockNodeR.lineWidth = 2.5
        self.blockNodeR.alpha = 0
        self.blockNodeR.position = CGPoint(x: edgeBlockX, y: edgeBlockY)
        self.blockNodeR.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.blockNodeR.physicsBody?.isDynamic = false
        self.blockNodeR.physicsBody?.categoryBitMask = pc.blockEdge
        self.blockNodeR.physicsBody?.collisionBitMask = pc.ball
        
        addChild(self.blockNode)
        addChild(self.blockNodeL)
        addChild(self.blockNodeR)
    }
    
    func setupBoundaryNode() {
        // Build the bottom boundary
        let size = CGSize(width: self.size.height, height: 1)
        let x = self.size.width/2
        let y = CGFloat(0)
        self.boundaryNode = SKShapeNode(rectOf: size)
        self.boundaryNode.lineWidth = 0
        self.boundaryNode.position = CGPoint(x: x, y: y)
        self.boundaryNode.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.boundaryNode.physicsBody?.restitution = 0.5
        self.boundaryNode.physicsBody?.isDynamic = false
        self.boundaryNode.physicsBody?.categoryBitMask = pc.boundary
        self.boundaryNode.physicsBody?.collisionBitMask = pc.ball
        self.boundaryNode.physicsBody?.contactTestBitMask = pc.none
        
        self.addChild(self.boundaryNode)
    }
    
    func spawnBall() {
        let w = ballSizes.ballWidth
        let x = CGFloat(arc4random() % UInt32(self.size.width))
        let y = self.size.height + w
        
        let netballNumber = arc4random() % 5 + 1
        let netballImage = "netball\(netballNumber)"
        let ball = SKSpriteNode(imageNamed: netballImage)
        ball.position = CGPoint(x: x, y: y)
        ball.size = CGSize(width: w, height: w)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: w/2)
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.categoryBitMask = pc.ball
        ball.physicsBody?.collisionBitMask = (pc.blockEdge | pc.blockBottom | pc.boundary | pc.ball)
        ball.physicsBody?.contactTestBitMask = (pc.blockBottom | pc.boundary)
        
        // Vanish after 10 seconds
        ball.run(SKAction.sequence([
            SKAction.wait(forDuration: 10),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]), completion: {
            self.ballNodes.removeAll(where: {$0 == ball})
        })
        
        self.ballNodes.append(ball)
        self.addChild(ball)
    }
    
    func showLevelNode() {
        // Display the level node with the current level
        self.levelNode.text = "Level \(self.level)"
        self.levelNode.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 1),
            SKAction.wait(forDuration: 2),
            SKAction.fadeOut(withDuration: 1)
        ]))
    }
    
    func beginLevel() {
        
        self.showLevelNode()
        
        let difficultyFactor = Double(truncating: pow(self.difficulty.rawValue, Double(self.level)) as NSNumber)
        
        let spawnSpeed = 1.0 / difficultyFactor
        let numberOfLevels = Int(15 * difficultyFactor)
        
        print("Starting level \(self.level), speed=\(spawnSpeed)")
        
        let level = SKAction.sequence([
            SKAction.run(spawnBall),
            SKAction.wait(forDuration: spawnSpeed)
            ])
        
        let runLevel = SKAction.sequence([
            SKAction.repeat(level, count: numberOfLevels),
            SKAction.run(increaseLevel)
        ])
        
        run(runLevel, withKey: "spawnBalls")
        
    }
    
    func increaseLevel() {
        self.level += 1
        self.beginLevel()
    }
    
    func moveBlock(toPosition pos: CGPoint) {
        // Only move when the game is in play
        guard self.state == .started else { return }
        
        // Limit how far the basket can move to prevent the ball from slipping through the walls
        let currentX = self.blockNode.position.x
        let diff = currentX-pos.x
        var newX = pos.x
        if diff >= ballSizes.ballWidth/2 {
            newX = currentX - ballSizes.ballWidth/2 - 0.1
        } else if diff <= -ballSizes.ballWidth/2 {
            newX = currentX + ballSizes.ballWidth/2 - 0.1
        }
        
        self.blockNode.position = CGPoint(x: newX, y: self.blockNode.position.y)
        
        var x = newX - blockSizes.bottomBlockWidth/2 - blockSizes.edgeBlockWidth/2
        let y = self.blockNode.position.y - blockSizes.bottomBlockHeight/2 + blockSizes.edgeBlockHeight/2
        self.blockNodeL.position = CGPoint(x: x, y: y)
        
        x = newX + blockSizes.bottomBlockWidth/2 + blockSizes.edgeBlockWidth/2
        self.blockNodeR.position = CGPoint(x: x, y: y)
    }
    
    func catchBall(_ ballNode: SKNode) {
        // Increment the score
        self.score += 1
        
        // Ensure the balls always disapear before they can spawn
        let speed = (1.0 / Double(truncating: pow(self.difficulty.rawValue, Double(self.level)) as NSNumber))/2
        
        // Don't allow this ball to call this again
        ballNode.physicsBody?.contactTestBitMask = pc.none
        ballNode.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: speed),
            SKAction.removeFromParent()
        ]))
    }
    
    // MARK: Button actions
    
    func playAgainTapped() {
        guard self.state == .ended else { return }
        
        // Fade out all nodes out to original positions
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        self.blockNode.run(fadeOutAction)
        self.blockNodeL.run(fadeOutAction)
        self.blockNodeR.run(fadeOutAction)
        self.gameStateNode.run(fadeOutAction)
        self.scoreNode.run(fadeOutAction)
        self.playAgainButton.run(fadeOutAction)
        self.quitButton.run(fadeOutAction)
        for ballNode in self.ballNodes {
            ballNode.run(fadeOutAction) {
                ballNode.removeFromParent()
                self.ballNodes.removeAll(where: {$0 == ballNode})
            }
        }
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run(showGameIntro)
        ]))
    }
    
    func quitTapped() {
        guard self.state == .ended else { return }
        
        self.gameDelegate.quitGame()
    }
    
    // MARK: Game state changers
    
    func showGameIntro() {
        self.state = .intro
        self.level = 1
        self.score = 0
        
        let fadeInTime = 0.7
        let fadeOutTime = 0.3
        
        self.gameStateNode.alpha = 0
        self.gameStateNode.text = "3"
        
        let intoSequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: fadeInTime),
            SKAction.fadeOut(withDuration: fadeOutTime),
            SKAction.run {
                self.gameStateNode.text = "2"
            },
            SKAction.fadeIn(withDuration: fadeInTime),
            SKAction.fadeOut(withDuration: fadeOutTime),
            SKAction.run {
                self.gameStateNode.text = "1"
            },
            SKAction.fadeIn(withDuration: fadeInTime),
            SKAction.fadeOut(withDuration: fadeOutTime),
            SKAction.run({
                self.blockNode?.run(SKAction.fadeIn(withDuration: fadeInTime))
                self.blockNodeL?.run(SKAction.fadeIn(withDuration: fadeInTime))
                self.blockNodeR?.run(SKAction.fadeIn(withDuration: fadeInTime))
                self.scoreNode.run(SKAction.fadeIn(withDuration: fadeInTime))
            }),
            SKAction.wait(forDuration: fadeInTime),
            SKAction.run(startGame)
        ])
        
        self.gameStateNode.run(intoSequence)
    }
    
    func startGame() {
        self.state = .started
        
        self.beginLevel()
    }
    
    func endGame() {
        self.state = .ended
        // Stop new balls from spawning
        removeAction(forKey: "spawnBalls")
        
        // Show the game over text and buttons
        let fadeInAction = SKAction.fadeIn(withDuration: 0.5)
        
        self.gameStateNode.text = "Game Over"
        self.gameStateNode.run(fadeInAction)
        self.playAgainButton.run(fadeInAction)
        self.quitButton.run(fadeInAction)
        
        // Save the score to the leaderboard
        self.gameDelegate.saveNewScore(self.score, difficulty: self.difficulty)
    }
}

// MARK: Touch Gestures

extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.moveBlock(toPosition: t.location(in: self)) }
        
        guard let position = touches.first?.location(in: self) else { return }
        if self.playAgainButton.contains(position) {
            self.playAgainTapped()
        } else if self.quitButton.contains(position) {
            self.quitTapped()
        }
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
        
        if self.state == .started {
            // Only bodyB should ever be the ball
            if contact.bodyB.categoryBitMask == pc.ball, let ballNode = contact.bodyB.node {
                // bodyA will either the the capturing basket or the boundary
                if contact.bodyA.categoryBitMask == pc.blockBottom {
                    self.catchBall(ballNode)
                } else if contact.bodyA.categoryBitMask == pc.boundary {
                    self.endGame()
                }
            }
        }
    }
}
