//
//  Storage.swift
//  TheGinnersGame
//
//  Created by Daniel Sykes-Turner on 20/7/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import Foundation

struct Storage {
    var username: String? {
        set(new) {
            UserDefaults.standard.set(new, forKey: "Username")
        }
        get {
            return UserDefaults.standard.string(forKey: "Username")
        }
    }
    var localLeaderboard: [Score] {
        set(new) {
            if let data = self.archiveObject(new) {
                UserDefaults.standard.set(data, forKey: "LocalLeaderboard")
            }
        }
        get {
            guard let data = UserDefaults.standard.object(forKey: "LocalLeaderboard") as? Data else { return [] }
            return self.unarchiveData(type: [Score].self, data: data) ?? []
        }
    }
    
    private func archiveObject<T>(_ object: T) -> Data? where T : Encodable {
        do {
            return try PropertyListEncoder().encode(object)
        } catch {
            print(error)
            return nil
        }
        
    }
    
    private func unarchiveData<T>(type: T.Type, data: Data) -> T? where T : Decodable {
        do {
            return try PropertyListDecoder().decode(type, from: data)
        } catch {
            print(error)
            return nil
        }
    }
}

struct Score: Comparable, Codable {
    var username: String
    var score: Int
    
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
}
