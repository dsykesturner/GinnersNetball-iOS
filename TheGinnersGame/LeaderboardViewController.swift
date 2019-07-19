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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
