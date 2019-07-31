//
//  Storage.swift
//  TheGinnersGame
//
//  Created by Daniel Sykes-Turner on 20/7/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import Foundation
import Firebase

class Storage: NSObject {
    private var firebaseStorage = FirebaseStorage()
    // User
    var username: String? {
        set(new) {
            Firebase.Analytics.logEvent("set_username", parameters: nil)
            UserDefaults.standard.set(new, forKey: "Username")
        }
        get {
            return UserDefaults.standard.string(forKey: "Username")
        }
    }
    // Leaderboards
    private(set) var localLeaderboardEasy: [Score] {
        set(new) {
            if let data = self.archiveObject(new) {
                UserDefaults.standard.set(data, forKey: "LocalLeaderboardEasy")
            }
        }
        get {
            guard let data = UserDefaults.standard.object(forKey: "LocalLeaderboardEasy") as? Data else { return [] }
            return self.unarchiveData(type: [Score].self, data: data) ?? []
        }
    }
    private(set) var localLeaderboardHard: [Score] {
        set(new) {
            if let data = self.archiveObject(new) {
                UserDefaults.standard.set(data, forKey: "LocalLeaderboardHard")
            }
        }
        get {
            guard let data = UserDefaults.standard.object(forKey: "LocalLeaderboardHard") as? Data else { return [] }
            return self.unarchiveData(type: [Score].self, data: data) ?? []
        }
    }
    private(set) var globalLeaderboardEasy: [Score] {
        set(new) {
            if let data = self.archiveObject(new) {
                UserDefaults.standard.set(data, forKey: "GloablLeaderboardEasy")
            }
        }
        get {
            guard let data = UserDefaults.standard.object(forKey: "GloablLeaderboardEasy") as? Data else { return [] }
            return self.unarchiveData(type: [Score].self, data: data) ?? []
        }
    }
    private(set) var globalLeaderboardHard: [Score] {
        set(new) {
            if let data = self.archiveObject(new) {
                UserDefaults.standard.set(data, forKey: "GloablLeaderboardHard")
            }
        }
        get {
            guard let data = UserDefaults.standard.object(forKey: "GloablLeaderboardHard") as? Data else { return [] }
            return self.unarchiveData(type: [Score].self, data: data) ?? []
        }
    }
    // Game progress
    var hasPlayedPracticeGame: Bool {
        set(new) {
            UserDefaults.standard.set(new, forKey: "HasPlayedPracticeGame")
        }
        get {
            return UserDefaults.standard.bool(forKey: "HasPlayedPracticeGame")
        }
    }
    var hasUnlockedHardMode: Bool {
        set(new) {
            UserDefaults.standard.set(new, forKey: "HasUnlockedHardMode")
        }
        get {
            return UserDefaults.standard.bool(forKey: "HasUnlockedHardMode")
        }
    }
    var hasShownPromptForUsername: Bool {
        set(new) {
            UserDefaults.standard.set(new, forKey: "HasShownPromptForUsername")
        }
        get {
            return UserDefaults.standard.bool(forKey: "HasShownPromptForUsername")
        }
    }
    
    
    override init() {
        super.init()
        
        self.globalLeaderboardEasy = []
        self.globalLeaderboardHard = []
        self.firebaseStorage.observeEasyLeaderboard { (newScore) in
            guard let newScore = newScore else { return }
            self.globalLeaderboardEasy.append(newScore)
            self.globalLeaderboardEasy.sort(by: {$0 > $1})
        }
        self.firebaseStorage.observeHardLeaderboard { (newScore) in
            guard let newScore = newScore else { return }
            self.globalLeaderboardHard.append(newScore)
            self.globalLeaderboardHard.sort(by: {$0 > $1})
        }
    }
    
    func saveScore(_ score: Int, difficulty: GameDifficulty) {
        guard let username = username else { return }
        let scoreModel = Score(username: username, score: score)
        
        // Add locally
        switch difficulty {
        case .practice:
            // Don't save practice scores
            break
        case .easy:
            self.localLeaderboardEasy.append(scoreModel)
            self.localLeaderboardEasy.sort(by: {$0 > $1})
        case .hard:
            self.localLeaderboardHard.append(scoreModel)
            self.localLeaderboardHard.sort(by: {$0 > $1})
        }
        // Add globally
        self.firebaseStorage.saveScore(scoreModel, difficulty: difficulty)
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
