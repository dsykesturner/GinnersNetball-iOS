//
//  Models.swift
//  TheGinnersGame
//
//  Created by Daniel Sykes-Turner on 20/7/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import Firebase

//struct User: Equatable, Codable {
//    var id: String
//    var username: String
//    
//    static func == (lhs: User, rhs: User) -> Bool {
//        return lhs.id < rhs.id
//    }
//}

struct ScoreList: Codable {
    var scores: [Score]
    
    init?(snapshot: DataSnapshot) {
        guard let values = snapshot.value as? [String:[String:AnyObject]] else { return nil }
        
        self.scores = []
        for value in values.values {
            if let score = Score(value: value) {
                self.scores.append(score)
            }
        }
    }
}

struct Score: Comparable, Codable {
    var id = UUID().uuidString
    var username: String
    var score: Int
    
    init(username: String, score: Int) {
        self.username = username
        self.score = score
    }
    
    init?(value: [String:AnyObject]) {
        guard let username = value["username"] as? String,
            let score = value["score"] as? Int else {
                return nil
        }
        
        self.username = username
        self.score = score
    }
    
    static func < (lhs: Score, rhs: Score) -> Bool {
        return lhs.score < rhs.score
    }
    static func <= (lhs: Score, rhs: Score) -> Bool {
        return lhs.score <= rhs.score
    }
    static func >= (lhs: Score, rhs: Score) -> Bool {
        return lhs.score >= rhs.score
    }
    static func > (lhs: Score, rhs: Score) -> Bool {
        return lhs.score > rhs.score
    }
    
    func toAnyObject() -> Any {
        return [
            "username": username,
            "score": score
        ]
    }
}
