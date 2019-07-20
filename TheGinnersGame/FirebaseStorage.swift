//
//  Database.swift
//  TheGinnersGame
//
//  Created by Daniel Sykes-Turner on 20/7/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import Foundation
import Firebase

class FirebaseStorage: NSObject {
    
    let easyLeaderboardRef = Database.database().reference(withPath: "leaderboard/easy")
    let hardLeaderboardRef = Database.database().reference(withPath: "leaderboard/hard")

    override init() {
        super.init()
    }
    
    func observeEasyLeaderboard(completion: ((Score?) -> Void)?) {
        let query = self.easyLeaderboardRef.queryOrdered(byChild: "score").queryLimited(toLast: 10)
        query.observe(.childAdded, with: { (snapshot) in
            if let value = snapshot.value as? [String:AnyObject] {
                completion?(Score(value: value))
            }
        })
    }
    
    func observeHardLeaderboard(completion: ((Score?) -> Void)?) {
        let query = self.hardLeaderboardRef.queryOrdered(byChild: "score").queryLimited(toLast: 10)
        query.observe(.childAdded, with: { (snapshot) in
            if let value = snapshot.value as? [String:AnyObject] {
                completion?(Score(value: value))
            }
        })
    }
    
    func saveScore(_ score: Score, difficulty: GameDifficulty) {
        switch difficulty {
        case .easy:
            let scoreRef = self.easyLeaderboardRef.childByAutoId()
            scoreRef.setValue(score.toAnyObject())
        case .hard:
            let scoreRef = self.hardLeaderboardRef.childByAutoId()
            scoreRef.setValue(score.toAnyObject())
        }
        
    }
}
