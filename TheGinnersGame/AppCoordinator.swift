//
//  AppCoordinator.swift
//  TheGinnersGame
//
//  Created by Daniel Sykes-Turner on 19/7/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import UIKit
import Firebase

class AppCoordinator: NSObject {
    let window: UIWindow
    let storage = Storage()
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func showIntroView() {
        let introVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IntroViewController") as! IntroViewController
        introVC.coordinator = self
        introVC.storage = self.storage
        self.window.rootViewController = introVC
        Firebase.Analytics.setScreenName("Intro Screen", screenClass: "IntroViewController")
    }
    
    func showGameView(difficulty: GameDifficulty) {
        let gameVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        gameVC.coordinator = self
        gameVC.gameDifficulty = difficulty
        gameVC.storage = self.storage
        self.window.rootViewController = gameVC
        Firebase.Analytics.setScreenName("Game Screen \(difficulty.toString())", screenClass: "GameViewController")
    }
    
    func showLeaderboardView() {
        let leaderboardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LeaderboardViewController") as! LeaderboardViewController
        leaderboardVC.coordinator = self
        leaderboardVC.storage = self.storage
        self.window.rootViewController = leaderboardVC
        Firebase.Analytics.setScreenName("Leaderboard Screen", screenClass: "GameViewController")
    }
}
