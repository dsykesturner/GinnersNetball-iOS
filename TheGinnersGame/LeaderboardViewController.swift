//
//  LeaderboardViewController.swift
//  TheGinnersGame
//
//  Created by Daniel Sykes-Turner on 19/7/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import UIKit

class LeaderboardViewController: UIViewController {

    @IBOutlet weak var easyLeaderboard: UILabel!
    @IBOutlet weak var hardLeaderboard: UILabel!
    
    weak var coordinator: AppCoordinator!
    var storage: Storage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadLocalLeaderboard()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func loadLocalLeaderboard() {
        self.loadLeaderboard(easyScores: self.storage.localLeaderboardEasy, hardScores: self.storage.localLeaderboardHard)
    }
    
    func loadGlobalLeaderboard() {
        self.loadLeaderboard(easyScores: self.storage.globalLeaderboardEasy, hardScores: self.storage.globalLeaderboardHard)
    }
    
    func loadLeaderboard(easyScores: [Score] = [], hardScores: [Score] = []) {
        // Load easy scores
        self.easyLeaderboard.text = nil
        for i in 0..<10 {
            if i < easyScores.count {
                let score = easyScores[i]
                if self.easyLeaderboard.text == nil {
                    self.easyLeaderboard.text = self.formatScore(score)
                } else {
                    self.easyLeaderboard.text = "\(self.easyLeaderboard.text!)\n\(self.formatScore(score))"
                }
            } else {
                if self.easyLeaderboard.text == nil {
                    self.easyLeaderboard.text = ""
                } else {
                    self.easyLeaderboard.text = "\(self.easyLeaderboard.text!)\n"
                }
            }
        }
        
        // Load hard scores
        self.hardLeaderboard.text = nil
        for i in 0..<10 {
            if i < hardScores.count {
                let score = hardScores[i]
                if self.hardLeaderboard.text == nil {
                    self.hardLeaderboard.text = self.formatScore(score)
                } else {
                    self.hardLeaderboard.text = "\(self.hardLeaderboard.text!)\n\(self.formatScore(score))"
                }
            } else {
                if self.hardLeaderboard.text == nil {
                    self.hardLeaderboard.text = ""
                } else {
                    self.hardLeaderboard.text = "\(self.hardLeaderboard.text!)\n"
                }
            }
        }
    }
    
    func formatScore(_ score: Score) -> String {
        if score.score >= 100 {
            return "\(score.score)\t\(score.username)"
        } else {
            return "\(score.score)\t\t\(score.username)"
        }
    }
    
    @IBAction func leaderboardRegionValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.loadLocalLeaderboard()
        } else {
            self.loadGlobalLeaderboard()
        }
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.coordinator.showIntroView()
    }
}
