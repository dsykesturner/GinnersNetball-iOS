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
    var storage: Storage!
    var gameDifficulty: GameDifficulty?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Setup game scene
            let scene = GameScene(size: view.frame.size)
            scene.scaleMode = .aspectFill
            scene.difficulty = self.gameDifficulty ?? .easy
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
    
    func saveNewScore(_ score: Int, difficulty: GameDifficulty) {
        // Attempt to get a username
        if self.storage.username == nil {
            let requestUsername = UIAlertController(title: "Save To Leaderboard", message: "Enter a username to save to the leaderboard", preferredStyle: .alert)
            requestUsername.addTextField { (textField) in
                textField.placeholder = "Username"
            }
            let save = UIAlertAction(title: "Save", style: .default) { (action) in
                guard let textField = requestUsername.textFields?.first,
                    let newUsername = textField.text,
                    newUsername.count > 0 else { return }
                self.storage.username = newUsername
                self.saveNewScore(score, difficulty: difficulty)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            requestUsername.addAction(save)
            requestUsername.addAction(cancel)
            self.present(requestUsername, animated: true, completion: nil)
            return
        }
        // Save the score if there is a username
        self.storage.saveScore(score, difficulty: difficulty)
    }
}
