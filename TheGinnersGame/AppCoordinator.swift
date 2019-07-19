//
//  AppCoordinator.swift
//  TheGinnersGame
//
//  Created by Daniel Sykes-Turner on 19/7/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import UIKit

class AppCoordinator: NSObject {
    let window: UIWindow
    let storage = Storage()
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func showIntroView() {
        let introVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IntroViewController") as! IntroViewController
        introVC.coordinator = self
        self.window.rootViewController = introVC
    }
    
    func showGameView(difficulty: LevelDifficulty) {
        let gameVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        gameVC.coordinator = self
        gameVC.storage = self.storage
        self.window.rootViewController = gameVC
    }
    
    func showLeaderboardView() {
        let leaderboardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LeaderboardViewController") as! LeaderboardViewController
        leaderboardVC.coordinator = self
        leaderboardVC.storage = self.storage
        self.window.rootViewController = leaderboardVC
    }
}
