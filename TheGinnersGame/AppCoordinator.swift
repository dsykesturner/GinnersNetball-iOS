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
    
    // MARK: - Router - Change views
    
    func showIntroView() {
        let introVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IntroViewController") as! IntroViewController
        introVC.coordinator = self
        introVC.storage = self.storage
        self.window.rootViewController = introVC
    }
    
    func showGameView(difficulty: GameDifficulty) {
        let gameVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        gameVC.coordinator = self
        gameVC.gameDifficulty = difficulty
        gameVC.storage = self.storage
        self.window.rootViewController = gameVC
    }
    
    func showLeaderboardView() {
        let leaderboardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LeaderboardViewController") as! LeaderboardViewController
        leaderboardVC.coordinator = self
        leaderboardVC.storage = self.storage
        self.window.rootViewController = leaderboardVC
    }
    
    func showStatsView() {
        let statsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StatsViewController") as! StatsViewController
        statsVC.coordinator = self
        statsVC.storage = self.storage
        self.window.rootViewController = statsVC
    }
}
