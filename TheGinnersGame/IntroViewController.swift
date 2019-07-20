//
//  IntroViewController.swift
//  TheGinnersGame
//
//  Created by Daniel Sykes-Turner on 19/7/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class IntroViewController: UIViewController {
    
    weak var coordinator: AppCoordinator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            
            let scene = IntroScene(size: view.frame.size)
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func easyTapped(_ sender: Any) {
        self.coordinator.showGameView(difficulty: .easy)
    }
    
    @IBAction func hardTapped(_ sender: Any) {
        self.coordinator.showGameView(difficulty: .hard)
    }
    
    @IBAction func leaderboardTapped(_ sender: Any) {
        self.coordinator.showLeaderboardView()
    }
}
