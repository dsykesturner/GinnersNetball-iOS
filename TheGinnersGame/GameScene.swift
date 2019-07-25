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
    static let netEdge: UInt32 = 0x1 << 2
    static let netBase: UInt32 = 0x1 << 3
    static let boundary: UInt32 = 0x1 << 4
}

struct layer {
    static let ball: CGFloat = 0
    static let net: CGFloat = 1
    static let text: CGFloat = 2
}

struct blockSizes {
    static let bottomBlockHeight:CGFloat = 30
    static let bottomBlockWidth:CGFloat = 100
    static let edgeBlockHeight:CGFloat = 150
    static let edgeBlockWidth:CGFloat = 30
}

struct netSizes {
    static let baseHeight:CGFloat = 41.0/3
    static let baseWidth:CGFloat = 224.0/3
    
    static let leftSideHeight:CGFloat = 391.0/3
    static let leftSideWidth:CGFloat = 114.0/3
    
    static let rightSideHeight:CGFloat = 393.0/3
    static let rightSideWidth:CGFloat = 114.0/3
    
    static let netHeight:CGFloat = 450.0/3
    static let netWidth:CGFloat = 444.0/3
}

struct ballSizes {
    static let ballWidth:CGFloat = 50
}

enum GameDifficulty: Double {
    case practice = 1.0
    case easy = 1.1
    case hard = 1.25
    
    func toString() -> String {
        switch self {
        case .practice:
            return "Practice"
        case .easy:
            return "Easy"
        case .hard:
            return "Hard"
        }
    }
}

enum GameState {
    case introPractice
    case intro
    case startedPractice
    case started
    case ended
}

enum PracticeStep {
    case step1
    case step2
    case step3
    case step4
    case step5
    case step6
    case step7
}

protocol GameSceneDelegate:class {
    func quitGame()
    func saveNewScore(_ score: Int, difficulty: GameDifficulty)
    func finishedPracticeGame()
}

class GameScene: SKScene {
    
    var scoreNode: SKLabelNode!
    var levelNode: SKLabelNode!
    var gameStateNode: SKLabelNode!
    var boundaryNode: SKShapeNode!
    var netBaseNode: SKSpriteNode!
    var netLeftSideNode: SKSpriteNode!
    var netRightSideNode: SKSpriteNode!
    var netWholeNode: SKSpriteNode!
    var ballNodes: [SKSpriteNode] = []
    var playAgainButton: SKLabelNode!
    var quitButton: SKLabelNode!
    
    weak var gameDelegate: GameSceneDelegate!
    
    var state: GameState = .started
    var practiceStep: PracticeStep = .step1
    var difficulty: GameDifficulty = .easy
    var level: Int = 1
    var score: Int = 0 {
        didSet {
            // Automatically update the score label
            self.scoreNode?.text = "\(self.score)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.setupNodes()
        
        if self.difficulty == .practice {
            self.startPracticeGame()
        } else {
            self.startGame()
        }
    }
    
    // MARK: Node rendering
    
    func setupNodes() {
        self.setupScoreNode()
        self.setupLevelNode()
        self.setupGameStateNodes()
        self.setupNetNodes()
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
        self.scoreNode.zPosition = layer.text
        self.addChild(self.scoreNode!)
    }
    
    func setupLevelNode() {
        let x = self.size.width / 2
        let y = self.scoreNode.position.y - self.scoreNode.frame.height - 10
        
        self.levelNode = SKLabelNode()
        self.levelNode.alpha = 0.0
        self.levelNode.position = CGPoint(x: x, y: y)
        self.levelNode.zPosition = layer.text
        
        self.addChild(self.levelNode)
    }
    
    func setupGameStateNodes() {
        let x = self.size.width * 0.5
        let gameStateY = self.size.height * 0.6

        self.gameStateNode = SKLabelNode()
        self.gameStateNode.position = CGPoint(x: x, y: gameStateY)
        self.gameStateNode.numberOfLines = 0
        self.gameStateNode.alpha = 0
        self.gameStateNode.zPosition = layer.text
        
        self.addChild(self.gameStateNode)
        
        let playAgainY = self.size.height * 0.4
        
        self.playAgainButton = SKLabelNode(text: "Play Again")
        self.playAgainButton.fontName = "HelveticaNeue-Medium"
        self.playAgainButton.position = CGPoint(x: x, y: playAgainY)
        self.playAgainButton.alpha = 0
        self.playAgainButton.zPosition = layer.text
        
        self.addChild(playAgainButton)
        
        let quitY = self.playAgainButton.position.y - self.playAgainButton.frame.height - 20
        
        self.quitButton = SKLabelNode(text: "Quit")
        self.quitButton.fontName = "HelveticaNeue-Medium"
        self.quitButton.position = CGPoint(x: x, y: quitY)
        self.quitButton.alpha = 0
        self.quitButton.zPosition = layer.text
        
        self.addChild(quitButton)
    }
    
    func setupNetNodes() {
        
        // Create the whole new node. This can't interact with anything
        self.netWholeNode = SKSpriteNode(imageNamed: "net-whole")
        self.netWholeNode.size = CGSize(width: netSizes.netWidth, height: netSizes.netHeight)
        self.netWholeNode.alpha = 0
        self.netWholeNode.zPosition = layer.net
        
        // Create the net base. This will interact with the ball and make it vanish on contact
        let baseTexture = SKTexture(imageNamed: "net-base")
        self.netBaseNode = SKSpriteNode(texture: baseTexture)
        self.netBaseNode.size = CGSize(width: netSizes.baseWidth, height: netSizes.baseHeight)
        self.netBaseNode.alpha = 0
        self.netBaseNode.zPosition = layer.net
        self.netBaseNode.physicsBody = SKPhysicsBody(texture: baseTexture, alphaThreshold: 0.3, size: baseTexture.size())
        self.netBaseNode.physicsBody?.isDynamic = false
        self.netBaseNode.physicsBody?.categoryBitMask = pc.netBase
        self.netBaseNode.physicsBody?.collisionBitMask = pc.none
        self.netBaseNode.physicsBody?.contactTestBitMask = pc.none
        
        
        // Create the left side of the net. This will interact with the ball but not do anything on contact
        let leftTexture = SKTexture(imageNamed: "net-left")
        self.netLeftSideNode = SKSpriteNode(texture: leftTexture)
        self.netLeftSideNode.size = CGSize(width: netSizes.leftSideWidth, height: netSizes.leftSideHeight)
        self.netLeftSideNode.alpha = 0
        self.netLeftSideNode.zPosition = layer.net
        self.netLeftSideNode.physicsBody = SKPhysicsBody(texture: leftTexture, alphaThreshold: 0.3, size: leftTexture.size())
        self.netLeftSideNode.physicsBody?.isDynamic = false
        self.netLeftSideNode.physicsBody?.categoryBitMask = pc.netEdge
        self.netLeftSideNode.physicsBody?.collisionBitMask = pc.ball

        // Create the right side of the net. This will interact with the ball but not do anything on contact
        let righTexture = SKTexture(imageNamed: "net-right")
        self.netRightSideNode = SKSpriteNode(texture: righTexture)
        self.netRightSideNode.size = CGSize(width: netSizes.rightSideWidth, height: netSizes.rightSideHeight)
        self.netRightSideNode.alpha = 0
        self.netRightSideNode.zPosition = layer.net
        self.netRightSideNode.physicsBody = SKPhysicsBody(texture: righTexture, alphaThreshold: 0.3, size: righTexture.size())
        self.netRightSideNode.physicsBody?.isDynamic = false
        self.netRightSideNode.physicsBody?.categoryBitMask = pc.netEdge
        self.netRightSideNode.physicsBody?.collisionBitMask = pc.ball
        
        // Set the starting position of the net
        self.moveBlock(toPosition: CGPoint(x: self.size.width/2, y: netSizes.netHeight - 30))
        
        self.addChild(self.netWholeNode)
        self.addChild(self.netBaseNode)
        self.addChild(self.netLeftSideNode)
        self.addChild(self.netRightSideNode)
    }
    
    func setupBoundaryNode() {
        // Build the bottom boundary
        let size = CGSize(width: self.size.height*10, height: 1)
        let x = self.size.width/2
        let y = CGFloat(0)
        self.boundaryNode = SKShapeNode(rectOf: size)
        self.boundaryNode.lineWidth = 0
        self.boundaryNode.position = CGPoint(x: x, y: y)
        self.boundaryNode.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.boundaryNode.physicsBody?.restitution = 0.5
        self.boundaryNode.physicsBody?.isDynamic = false
        self.boundaryNode.physicsBody?.categoryBitMask = pc.boundary
        self.boundaryNode.physicsBody?.collisionBitMask = pc.none
        self.boundaryNode.physicsBody?.contactTestBitMask = pc.none
        
        self.addChild(self.boundaryNode)
    }
    
    func spawnBall() {
        let w = ballSizes.ballWidth
        // Stay within 90% of the screen's width
        let x = CGFloat(arc4random() % UInt32(self.size.width*0.8) + UInt32(self.size.width*0.1))
        let y = self.size.height + w
        // Add random horizontal velocity on hard mode
        let xVelocity = self.difficulty == .hard ? (Double(arc4random() % 100)) / 1.0 - 50.0 : 0.0
        
        let netballNumber = arc4random() % 5 + 1
        let netballImage = "netball\(netballNumber)"
        let ball = SKSpriteNode(imageNamed: netballImage)
        ball.position = CGPoint(x: x, y: y)
        ball.size = CGSize(width: w, height: w)
        ball.zPosition = layer.ball
        ball.physicsBody = SKPhysicsBody(circleOfRadius: w/2)
        ball.physicsBody?.velocity = CGVector(dx: xVelocity, dy: 0)
        ball.physicsBody?.affectedByGravity = true
        ball.physicsBody?.categoryBitMask = pc.ball
        // Ignore falling balls during the intro sequence of the practice round
        if self.state == .introPractice {
            ball.physicsBody?.collisionBitMask = (pc.boundary | pc.ball)
            ball.physicsBody?.contactTestBitMask = (pc.boundary)
        } else {
            ball.physicsBody?.collisionBitMask = (pc.netEdge | pc.boundary | pc.ball)
            ball.physicsBody?.contactTestBitMask = (pc.netBase | pc.boundary)
        }
        
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
            SKAction.wait(forDuration: 1),
            SKAction.fadeOut(withDuration: 1)
        ]))
    }
    
    func setGameStateText(_ text: String) {
        let attrString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let range = NSRange(location: 0, length: text.count)
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
        attrString.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-UltraLight", size: 32)!], range: range)
        self.gameStateNode.attributedText = attrString
    }
    
    // MARK: Game actions
    
    func beginLevel() {
        
        self.showLevelNode()
        
        let difficultyFactor = Double(truncating: pow(self.difficulty.rawValue, Double(self.level)) as NSNumber)
        
        let spawnSpeed = 1.0 / difficultyFactor
        let numberOfLevels = Int(15 * difficultyFactor)
        
        print("Starting level \(self.level), speed=\(spawnSpeed)")
        
        let level = SKAction.sequence([
            SKAction.run(self.spawnBall),
            SKAction.wait(forDuration: spawnSpeed)
            ])
        
        let runLevel = SKAction.sequence([
            SKAction.repeat(level, count: numberOfLevels),
            SKAction.run(self.increaseLevel)
        ])
        
        run(runLevel, withKey: "spawnBalls")
    }
    
    func increaseLevel() {
        self.level += 1
        self.beginLevel()
    }
    
    func moveBlock(towardsPosition pos: CGPoint) {
        // Only move when the game has not ended
        guard self.state != .ended else { return }
        // Trigger the next step if we're in practice
        if self.state == .introPractice && self.practiceStep == .step2 {
            self.practiceStep = .step3
            self.showPractice()
        }
        
        // Limit how far the basket can move to prevent the ball from slipping through the walls
        let currentX = self.netWholeNode.position.x
        let diff = currentX-pos.x
        var newX = pos.x
        if diff >= ballSizes.ballWidth/2 {
            newX = currentX - ballSizes.ballWidth/2 - 0.1
        } else if diff <= -ballSizes.ballWidth/2 {
            newX = currentX + ballSizes.ballWidth/2 - 0.1
        }
        
        self.moveBlock(toX: newX)
    }
    
    func moveBlock(toX x: CGFloat) {
        // Move only the net's x position
        self.moveBlock(toPosition: CGPoint(x: x, y: self.netWholeNode.position.y))
    }
    
    func moveBlock(toPosition pos: CGPoint) {
        // Move the net to an exact position
        var x = pos.x
        var y = pos.y
        self.netWholeNode.position = CGPoint(x: x, y: y)
        
        y = self.netWholeNode.position.y - netSizes.netHeight/2 + netSizes.baseHeight/2
        self.netBaseNode.position = CGPoint(x: x, y: y)

        x = self.netWholeNode.position.x - netSizes.netWidth/2 + netSizes.leftSideWidth/2
        y = self.netWholeNode.position.y
        self.netLeftSideNode.position = CGPoint(x: x, y: y)
        
        x = self.netWholeNode.position.x + netSizes.netWidth/2 - netSizes.rightSideWidth/2
        y = self.netWholeNode.position.y
        self.netRightSideNode.position = CGPoint(x: x, y: y)
    }
    
    func catchBall(_ ballNode: SKNode) {
        // Increment the score
        self.score += 1
        
        // Ensure the balls always disapear before they can spawn
        let speed = (1.0 / Double(truncating: pow(self.difficulty.rawValue, Double(self.level)) as NSNumber))/2
        
        // Allow the ball to fall through the floor
        if self.state == .introPractice {
            // The ball shouldn't ever interact with the net
            ballNode.physicsBody?.collisionBitMask = pc.ball
        } else {
            ballNode.physicsBody?.collisionBitMask = (pc.ball | pc.netEdge)
        }
        // Don't allow this ball to call this again
        ballNode.physicsBody?.contactTestBitMask = pc.none
        ballNode.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: speed),
            SKAction.removeFromParent()
        ]))
    }
    
    // MARK: Game state changers
    
    func showGameIntro(completion: @escaping () -> Void) {
        self.state = .intro
        self.level = 1
        self.score = 0
        
        let fadeInTime = 0.7
        let fadeOutTime = 0.3
        
        self.gameStateNode.alpha = 0
        self.setGameStateText("3")
        
        let intoSequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: fadeInTime),
            SKAction.fadeOut(withDuration: fadeOutTime),
            SKAction.run {
                self.setGameStateText("2")
            },
            SKAction.fadeIn(withDuration: fadeInTime),
            SKAction.fadeOut(withDuration: fadeOutTime),
            SKAction.run {
                self.setGameStateText("1")
            },
            SKAction.fadeIn(withDuration: fadeInTime),
            SKAction.fadeOut(withDuration: fadeOutTime),
            SKAction.run({
                self.scoreNode.run(SKAction.fadeIn(withDuration: fadeInTime))
            }),
            SKAction.wait(forDuration: fadeInTime),
            SKAction.run(completion)
        ])
        
        self.gameStateNode.run(intoSequence)
        self.netWholeNode.run(SKAction.fadeIn(withDuration: fadeInTime))
        self.netBaseNode.run(SKAction.fadeIn(withDuration: fadeInTime))
        self.netLeftSideNode.run(SKAction.fadeIn(withDuration: fadeInTime))
        self.netRightSideNode.run(SKAction.fadeIn(withDuration: fadeInTime))
    }
    
    func showGameOutro(completion: @escaping () -> Void) {
        // Fade out all nodes out to original positions
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        self.netWholeNode.run(fadeOutAction)
        self.netBaseNode.run(fadeOutAction)
        self.netLeftSideNode.run(fadeOutAction)
        self.netRightSideNode.run(fadeOutAction) {
            // Return the block to center screen
            self.moveBlock(toX: self.size.width/2)
        }
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
            SKAction.run(completion)
        ]))
    }
    
    func showGameOver(completion: @escaping () -> Void) {
        // Show the game over text and buttons
        let fadeInAction = SKAction.fadeIn(withDuration: 0.5)
        
        self.setGameStateText("Game Over")
        self.gameStateNode.run(fadeInAction)
        self.playAgainButton.run(fadeInAction)
        self.quitButton.run(fadeInAction)
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run(completion)
        ]))
    }
    
    func showPractice() {
        
        let fadeTime = 0.5
        
        switch self.practiceStep {
        case .step1:
            self.state = .introPractice
            self.setGameStateText("Netballs will fall from\nabove")
            self.gameStateNode.run(SKAction.sequence([
                SKAction.fadeIn(withDuration: fadeTime),
                SKAction.wait(forDuration: 0.5),
                SKAction.run(self.spawnBall),
                SKAction.wait(forDuration: 2),
                SKAction.fadeOut(withDuration: fadeTime),
                SKAction.run {
                    self.setGameStateText("Catch them in this\nnet")
                    self.netWholeNode.run(SKAction.fadeIn(withDuration: fadeTime))
                    self.netBaseNode.run(SKAction.fadeIn(withDuration: fadeTime))
                    self.netLeftSideNode.run(SKAction.fadeIn(withDuration: fadeTime))
                    self.netRightSideNode.run(SKAction.fadeIn(withDuration: fadeTime))
                },
                SKAction.fadeIn(withDuration: fadeTime),
                SKAction.wait(forDuration: 2),
                SKAction.fadeOut(withDuration: fadeTime),
                SKAction.run {
                    self.practiceStep = .step2
                    self.showPractice()
                }
            ]))
        case .step2:
            self.gameStateNode.run(SKAction.sequence([
                SKAction.run {
                    self.setGameStateText("Pan your finger to move\nit from side to side")
                },
                SKAction.fadeIn(withDuration: fadeTime),
            ]))
        case .step3:
            self.state = .startedPractice
            self.gameStateNode.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.5),
                SKAction.fadeOut(withDuration: fadeTime),
                SKAction.run {
                    self.setGameStateText("Time to test out\nthose netball skills...")
                },
                SKAction.fadeIn(withDuration: fadeTime),
                SKAction.wait(forDuration: 1.5),
                SKAction.fadeOut(withDuration: fadeTime),
                SKAction.run {
                    self.setGameStateText("Try to catch three\nin a row")
                },
                SKAction.fadeIn(withDuration: fadeTime),
                SKAction.wait(forDuration: 1.5),
                SKAction.fadeOut(withDuration: fadeTime),
                SKAction.run(self.spawnBall)
            ]))
        case .step4:
            self.gameStateNode.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: fadeTime),
                SKAction.run {
                    let randomQuote = arc4random() % 5
                    if randomQuote == 0 {
                        self.setGameStateText("Good pressure,\ngive it another go")
                    } else if randomQuote == 1 {
                        self.setGameStateText("Good try,\ngive it another go")
                    } else if randomQuote == 2 {
                        self.setGameStateText("Good effort,\ngive it another go")
                    } else if randomQuote == 3 {
                        self.setGameStateText("Good arms,\ngive it another go")
                    } else if randomQuote == 4 {
                        self.setGameStateText("Good movement,\ngive it another go")
                    }
                },
                SKAction.fadeIn(withDuration: fadeTime),
                SKAction.wait(forDuration: 1),
                SKAction.fadeOut(withDuration: fadeTime),
                SKAction.run(self.spawnBall)
            ]))
        case .step5, .step6:
            self.spawnBall()
        case .step7:
            self.gameStateNode.run(SKAction.sequence([
                SKAction.fadeOut(withDuration: fadeTime),
                SKAction.run {
                    self.setGameStateText("Great work! You're\nready for the real game")
                },
                SKAction.fadeIn(withDuration: fadeTime),
                SKAction.wait(forDuration: 2),
                SKAction.fadeOut(withDuration: fadeTime),
                SKAction.run {
                    self.setGameStateText("Get ready...")
                },
                SKAction.fadeIn(withDuration: fadeTime),
                SKAction.wait(forDuration: 1),
                SKAction.fadeOut(withDuration: fadeTime),
                SKAction.run {
                    self.gameDelegate.finishedPracticeGame()
                    self.difficulty = .easy
                    self.startGame()
                }
            ]))
        }
    }
    
    func startGame() {
        self.showGameIntro {
            self.state = .started
            self.beginLevel()
        }
    }
    
    func startPracticeGame() {
        self.practiceStep = .step1
        self.showPractice()
    }
    
    func endGame() {
        self.state = .ended
        // Stop new balls from spawning
        removeAction(forKey: "spawnBalls")
        
        self.showGameOver {
            // Save the score to the leaderboard
            self.gameDelegate.saveNewScore(self.score, difficulty: self.difficulty)
        }
    }
    
    // MARK: Button actions
    
    func playAgainTapped() {
        guard self.state == .ended else { return }
        self.showGameOutro {
            self.startGame()
        }
    }
    
    func quitTapped() {
        guard self.state == .ended else { return }
        self.showGameOutro {
            self.gameDelegate.quitGame()
        }
    }
}

// MARK: Touch Gestures

extension GameScene {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.moveBlock(towardsPosition: t.location(in: self)) }
        
        guard let position = touches.first?.location(in: self) else { return }
        if self.playAgainButton.contains(position) {
            self.playAgainTapped()
        } else if self.quitButton.contains(position) {
            self.quitTapped()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.moveBlock(towardsPosition: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
}

// MARK: SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        
        // Only bodyB should ever be the ball
        guard contact.bodyB.categoryBitMask == pc.ball,
            let ballNode = contact.bodyB.node,
            ballNode.physicsBody?.contactTestBitMask != pc.none else { return }
        
        switch self.state {
        case .startedPractice:
            self.catchBall(ballNode)
            // bodyA will either the the capturing basket or the boundary
            if contact.bodyA.categoryBitMask == pc.netBase {
                if self.practiceStep == .step3 {
                    self.practiceStep = .step5
                } else if self.practiceStep == .step4 {
                    self.practiceStep = .step5
                } else if self.practiceStep == .step5 {
                    self.practiceStep = .step6
                } else if self.practiceStep == .step6 {
                    self.practiceStep = .step7
                }
                self.showPractice()
            } else if contact.bodyA.categoryBitMask == pc.boundary {
                self.practiceStep = .step4
                self.showPractice()
            }
        case .started:
            // bodyA will either the the capturing basket or the boundary
            if contact.bodyA.categoryBitMask == pc.netBase {
                self.catchBall(ballNode)
            } else if contact.bodyA.categoryBitMask == pc.boundary {
                self.endGame()
            }
        case .introPractice:
            // Remove any balls spawned during practice
            self.catchBall(ballNode)
        default:
            break
        }
    }
}
