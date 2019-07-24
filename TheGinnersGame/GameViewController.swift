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
            scene.gameDelegate = self
            if (!self.storage.hasPlayedPracticeGame) {
                scene.difficulty = .practice
            } else {
                scene.difficulty = self.gameDifficulty ?? .easy
            }
            
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
    
    func unlockHardMode(closed: (() -> Void)?) {
        self.storage.hasUnlockedHardMode = true
        // Show unlock message
        let alertView = UIAlertController(title: "Hard Mode Unlocked", message: "You have unlocked hard mode", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            closed?()
        }))
        self.present(alertView, animated: true, completion: nil)
    }
    
    func requestForUsername(closed: (() -> Void)?) {
        self.storage.hasShownPromptForUsername = true
        // Ask for a username to save the score
        let requestUsername = UIAlertController(title: "Save To Leaderboard", message: "Enter a username to save to the leaderboard", preferredStyle: .alert)
        requestUsername.addTextField { (textField) in
            textField.placeholder = "Username"
        }
        let save = UIAlertAction(title: "Save", style: .default) { (action) in
            guard let textField = requestUsername.textFields?.first,
                let newUsername = textField.text,
                newUsername.count > 0 else { return }
            self.storage.username = newUsername
            closed?()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            closed?()
        })
        requestUsername.addAction(save)
        requestUsername.addAction(cancel)
        self.present(requestUsername, animated: true, completion: nil)
    }
}

extension GameViewController: GameSceneDelegate {
    
    func quitGame() {
        self.coordinator.showIntroView()
    }
    
    func saveNewScore(_ score: Int, difficulty: GameDifficulty) {
        // Unlock hard mode
        if self.storage.hasUnlockedHardMode == false && score > 100 {
            self.unlockHardMode {
                self.saveNewScore(score, difficulty: difficulty)
            }
            return
        }
        // Attempt to get a username
        if self.storage.hasShownPromptForUsername == false {
            self.requestForUsername {
                self.saveNewScore(score, difficulty: difficulty)
            }
            return
        }
        // Save the score
        self.storage.saveScore(score, difficulty: difficulty)
    }
    
    func finishedPracticeGame() {
        self.storage.hasPlayedPracticeGame = true
    }
}
