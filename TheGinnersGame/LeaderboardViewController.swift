//
//  LeaderboardViewController.swift
//  TheGinnersGame
//
//  Created by Daniel Sykes-Turner on 19/7/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import UIKit

class LeaderboardViewController: UIViewController {

    @IBOutlet weak var leaderboardLabel: UILabel!
    
    weak var coordinator: AppCoordinator!
    var storage: Storage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadLocalLeaderboard()
    }
    
    func loadLocalLeaderboard() {
        self.loadLeaderboard(scores: self.storage.localLeaderboard)
    }
    
    func loadGlobalLeaderboard() {
        self.loadLeaderboard(scores: self.storage.globalLeaderboard)
    }
    
    func loadLeaderboard(scores: [Score] = []) {
        self.leaderboardLabel.text = nil
        
        var count = 1
        for score in scores {
            if self.leaderboardLabel.text == nil {
                self.leaderboardLabel.text = "\(score.score) \(score.username)"
            } else {
                self.leaderboardLabel.text = "\(self.leaderboardLabel.text!)\n\(score.score) \(score.username)"
            }
            
            count += 1
            // Just show the top 10 scores
            if count == 11 {
                break
            }
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
