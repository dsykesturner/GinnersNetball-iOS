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
    
    func saveNewScore(_ score: Int) {
        // Attempt to get a username
        guard let username = self.storage.username else {
            let requestUsername = UIAlertController(title: "Save To Leaderboard", message: "Enter a username to save to the leaderboard", preferredStyle: .alert)
            requestUsername.addTextField { (textField) in
                textField.placeholder = "Username"
            }
            let save = UIAlertAction(title: "Save", style: .default) { (action) in
                guard let textField = requestUsername.textFields?.first,
                    let newUsername = textField.text,
                    newUsername.count > 0 else { return }
                self.storage.username = newUsername
                self.saveNewScore(score)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            requestUsername.addAction(save)
            requestUsername.addAction(cancel)
            self.present(requestUsername, animated: true, completion: nil)
            return
        }
        // Save the score if there is a username
        let scoreModel = Score(username: username, score: score)
        var leaderboard = self.storage.localLeaderboard
        leaderboard.append(scoreModel)
        leaderboard.sort(by: {$0 > $1})
        self.storage.localLeaderboard = leaderboard
    }
}
