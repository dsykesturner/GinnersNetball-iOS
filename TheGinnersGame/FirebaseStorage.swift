//
//  Database.swift
//  TheGinnersGame
//
//  Created by Daniel Sykes-Turner on 20/7/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import Firebase

class FirebaseStorage: NSObject {
    
    let easyLeaderboardRef = Database.database().reference(withPath: "leaderboard/easy")
    let hardLeaderboardRef = Database.database().reference(withPath: "leaderboard/hard")
    let usersRef = Database.database().reference(withPath: "users")
    
    override init() {
        super.init()
        
        Auth.auth().signInAnonymously { (authResult, error) in
            if let error = error {
                print("Failed to sign in: \(error)")
            } else if let user = authResult?.user {
                // User signed in
                print("user \(user.uid) signed in")
                self.login(user: user)
            } else {
                // User signed out
                print("user signed out")
            }
        }
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
        case .practice:
            // Don't save practice scores
            break
        case .easy:
            let scoreRef = self.easyLeaderboardRef.childByAutoId()
            scoreRef.setValue(score.toAnyObject())
        case .hard:
            let scoreRef = self.hardLeaderboardRef.childByAutoId()
            scoreRef.setValue(score.toAnyObject())
        }
    }
    
    func login(user: User) {
        let singleUserRef = self.usersRef.child(user.uid)
        singleUserRef.setValue(Date().timeIntervalSince1970)
    }
}
