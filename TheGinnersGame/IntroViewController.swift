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
    
    @IBOutlet weak var hardButton: UIButton!
    weak var coordinator: AppCoordinator!
    var storage: Storage!
    
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
        
        // Lock/unlock hard mode
        self.hardButton.alpha = self.storage.hasUnlockedHardMode ? 1.0 : 0.5
            
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func easyTapped(_ sender: Any) {
        self.coordinator.showGameView(difficulty: .easy)
    }
    
    @IBAction func hardTapped(_ sender: Any) {
        if self.storage.hasUnlockedHardMode {
            self.coordinator.showGameView(difficulty: .hard)
        } else {
            let alertView = UIAlertController(title: "Hard Mode Locked", message: "Score over 100 points to unlock hard mode", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    @IBAction func leaderboardTapped(_ sender: Any) {
        self.coordinator.showLeaderboardView()
    }
}
