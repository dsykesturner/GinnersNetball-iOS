//
//  IntroScene.swift
//  TheGinnersGame
//
//  Created by Daniel Sykes-Turner on 19/7/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class IntroScene: SKScene {
    
    var motion:CMMotionManager?
    
    override func didMove(to view: SKView) {
        
        self.setupScenePhysics()
        self.setupAccelerometer()
        self.spawnNetballs(-1)
        
//        Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(removeScenePhysics), userInfo: nil, repeats: true)
    }
    
    private func setupAccelerometer() {
        
        if motion == nil {
            motion = CMMotionManager()
        }
        
        if motion!.isAccelerometerActive == false {
            motion!.accelerometerUpdateInterval = 1.0/60.0
            motion!.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
                if let error = error {
                    print("Error encountered getting accelerometer data \(error)")
                } else if let data = data {
                    DispatchQueue.main.async {
//                        if (self.orientation == .landscapeRight) {
//                            self.physicsWorld.gravity = CGVector(dx: -data.acceleration.y*10, dy: data.acceleration.x*10)
//                        } else if (self.orientation == .landscapeLeft) {
//                            self.physicsWorld.gravity = CGVector(dx: data.acceleration.y*10, dy: -data.acceleration.x*10)
//                        }  else if (self.orientation == .portrait) {
                            self.physicsWorld.gravity = CGVector(dx: data.acceleration.x*15, dy: data.acceleration.y*15-3)
//                        } else if (self.orientation == .portraitUpsideDown) {
//                            self.physicsWorld.gravity = CGVector(dx: -data.acceleration.x*10, dy: -data.acceleration.y*10)
//                        }
                    }
                }
            }
        }
        
    }
    
    @objc
    func setupScenePhysics() {
        self.physicsWorld.contactDelegate = self
//        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        if self.physicsBody == nil {
            // Create an invisible barrier around the scene to keep the ball inside
            let sceneBound = SKPhysicsBody(edgeLoopFrom: self.frame)
            self.physicsBody = sceneBound
        }
    }
    
    @objc
    func removeScenePhysics() {
        self.physicsBody = nil
        
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(setupScenePhysics), userInfo: nil, repeats: false)
    }
    
    func spawnNetballs(_ numberOfNetballs: Int) {
        
        let spawnAction = SKAction.sequence([SKAction.run(spawnBall),
                                             SKAction.wait(forDuration: 0.7)])
        
        if numberOfNetballs == -1 {
            run(SKAction.repeatForever(spawnAction))
        } else {
            run(SKAction.repeat(spawnAction, count: numberOfNetballs))
        }
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
        ball.physicsBody?.restitution = 0.5
        
        // Vanish after 20 seconds
        ball.run(SKAction.sequence([
            SKAction.wait(forDuration: 60),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
        
        self.addChild(ball)
    }
}

extension IntroScene: SKPhysicsContactDelegate {
    
}
