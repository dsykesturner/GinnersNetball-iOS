//
//  Storage.swift
//  TheGinnersGame
//
//  Created by Daniel Sykes-Turner on 20/7/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import Firebase

class Storage: NSObject {
    private var firebaseStorage = FirebaseStorage()
    var username: String? {
        set(new) {
            UserDefaults.standard.set(new, forKey: "Username")
        }
        get {
            return UserDefaults.standard.string(forKey: "Username")
        }
    }
    private(set) var localLeaderboard: [Score] {
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
    private(set) var globalLeaderboard: [Score] {
        set(new) {
            if let data = self.archiveObject(new) {
                UserDefaults.standard.set(data, forKey: "GloablLeaderboard")
            }
        }
        get {
            guard let data = UserDefaults.standard.object(forKey: "GloablLeaderboard") as? Data else { return [] }
            return self.unarchiveData(type: [Score].self, data: data) ?? []
        }
    }
    
    override init() {
        super.init()
        
        self.globalLeaderboard = []
        self.firebaseStorage.observeLeaderboard { (newScore) in
            guard let newScore = newScore else { return }
            self.globalLeaderboard.append(newScore)
            self.globalLeaderboard.sort(by: {$0 > $1})
        }
    }
    
    func saveScore(_ score: Int) {
        guard let username = username else { return }
        let scoreModel = Score(username: username, score: score)
        // Add locally
        self.localLeaderboard.append(scoreModel)
        self.localLeaderboard.sort(by: {$0 > $1})
        // Add globally
        self.firebaseStorage.saveScore(scoreModel)
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
