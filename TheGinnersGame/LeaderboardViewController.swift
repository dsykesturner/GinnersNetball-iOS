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
        
        self.leaderboardLabel.text = nil
        
        var count = 1
        for score in storage.localLeaderboard {
            if self.leaderboardLabel.text == nil {
                self.leaderboardLabel.text = "\(count). \(score.score) \(score.username)"
            } else {
                self.leaderboardLabel.text = "\(self.leaderboardLabel.text!)\n\(count). \(score.score) \(score.username)"
            }
            
            count += 1
            // Just show the top 10 scores
            if count == 11 {
                break
            }
        }
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.coordinator.showIntroView()
    }
}
