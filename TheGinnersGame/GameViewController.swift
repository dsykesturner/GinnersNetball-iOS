//
//  GameViewController.swift
//  TheGinnersGame
//
//  Created by Daniel Sykes-Turner on 15/7/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    weak var coordinator: AppCoordinator!
    var levelDifficulty: LevelDifficulty?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Setup game scene
            let scene = GameScene(size: view.frame.size)
            scene.scaleMode = .aspectFill
            scene.difficulty = self.levelDifficulty ?? .easy
            scene.gameDelegate = self
            
            // Setup view
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func showIntoView() {
        self.coordinator.showIntroView()
    }
}

extension GameViewController: GameSceneDelegate {
    
    func quitGame() {
        self.coordinator.showIntroView()
    }
}
