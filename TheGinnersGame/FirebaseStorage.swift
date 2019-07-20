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
    
    let ref = Database.database().reference(withPath: "leaderboard")

    override init() {
        super.init()
    }
    
    func observeLeaderboard(completion: ((Score?) -> Void)?) {
        let query = self.ref.queryOrdered(byChild: "score").queryLimited(toLast: 10)
        query.observe(.childAdded, with: { (snapshot) in
            print(snapshot)
            if let value = snapshot.value as? [String:AnyObject] {
                completion?(Score(value: value))
            }
        })
    }
    
    func saveScore(_ score: Score) {
        let scoreRef = self.ref.childByAutoId()
        scoreRef.setValue(score.toAnyObject())
    }
}
