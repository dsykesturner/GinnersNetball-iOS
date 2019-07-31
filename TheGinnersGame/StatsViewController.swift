//
//  StatsViewController.swift
//  TheGinnersGame
//
//  Created by Daniel Sykes-Turner on 31/7/19.
//  Copyright © 2019 Daniel Sykes-Turner. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {

    @IBOutlet weak var statsLabel: UITextView!
    
    weak var coordinator: AppCoordinator!
    var storage: Storage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calculateAllStats()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: Actions
    
    @IBAction func closeTapped(_ sender: Any) {
        self.coordinator.showLeaderboardView()
    }
}

extension StatsViewController {
    // MARK: Calculations for game stats
    
    func calculateSpawnSpeed(difficultyFactor: Double) -> Double {
        return 1.0 / difficultyFactor
    }
    
    func calculateNumberOfLevels(difficultyFactor: Double) -> Int {
        return Int(15 * difficultyFactor)
    }
    
    func calculateDifficultyFactor(difficulty: GameDifficulty, level: Int) -> Double {
        return Double(truncating: pow(difficulty.rawValue, Double(level)) as NSNumber)
    }
    
    func calculateSpawnSpeedAndLevelCount(difficulty: GameDifficulty, level: Int) -> (Double, Int) {
        let difficultyFactor = calculateDifficultyFactor(difficulty: difficulty, level: level)
        let spawnSpeed = calculateSpawnSpeed(difficultyFactor: difficultyFactor)
        let numberOfLevels = calculateNumberOfLevels(difficultyFactor: difficultyFactor)
        
        return (spawnSpeed, numberOfLevels)
    }
    
    func calculateGameTimeSeconds(difficulty: GameDifficulty, score: Int) -> Double {
        
        var score = score
        var gameTime = 0.0
        var level = 1
        
        while score > 0 {
            let (spawnSpeed, numberOfLevels) = calculateSpawnSpeedAndLevelCount(difficulty: difficulty, level: level)
            let levelsToRemove = score < numberOfLevels ? score : numberOfLevels
            
            gameTime += spawnSpeed * Double(levelsToRemove)
            score -= levelsToRemove
            level += 1
        }
        
        return gameTime
    }
    
    func calculateAllStats() {
        
        let easyScores = storage.localLeaderboardEasy
        let hardScores = storage.localLeaderboardHard
        
        var easyGameTimes:[Double] = []
        var hardGameTimes:[Double] = []
        var easyGameTimeSum = 0.0
        var hardGameTimeSum = 0.0
        var easyScoresSum = 0
        var hardScoresSum = 0
        
        // Loop through every score and add up the stats
        for score in easyScores {
            let gameTime = self.calculateGameTimeSeconds(difficulty: .easy, score: score.score)
            easyGameTimes.append(gameTime)
            easyGameTimeSum += gameTime
            easyScoresSum += score.score
        }
        for score in hardScores {
            let gameTime = self.calculateGameTimeSeconds(difficulty: .hard, score: score.score)
            hardGameTimes.append(gameTime)
            hardGameTimeSum += gameTime
            hardScoresSum += score.score
        }
        
        // Total Games
        let totalGames:Int = easyGameTimes.count + hardGameTimes.count
        
        // Total Game Time
        let totalGameTime:Double = easyGameTimeSum + hardGameTimeSum
        
        // Average Game Time
        let aveGameTime:Double = totalGames > 0 ? totalGameTime / Double(totalGames) : 0
        
        // Total Score
        let totalScore:Int = easyScoresSum + hardScoresSum
        
        // Average Score
        let averageScoreEasy:Double = easyGameTimes.count > 0 ? Double(easyScoresSum) / Double(easyGameTimes.count) : 0
        let averageScoreHard:Double = hardGameTimes.count > 0 ? Double(hardScoresSum) / Double(hardGameTimes.count) : 0
        
        self.showStats(totalGameTime: totalGameTime, aveGameTime: aveGameTime, totalScore: totalScore, averageScoreEasy: averageScoreEasy, averageScoreHard: averageScoreHard, totalGames: totalGames)
    }
    
    func showStats(totalGameTime: Double, aveGameTime: Double, totalScore: Int, averageScoreEasy: Double, averageScoreHard: Double, totalGames: Int) {
        
        let rightAlignStyle = NSMutableParagraphStyle()
        rightAlignStyle.alignment = .right
        let rightAlign = [
            NSAttributedString.Key.paragraphStyle: rightAlignStyle,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 25)!
        ]
        let regular = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Thin", size: 25)!
        ]
        
        // Create formated strings from the stats
        let totalGameTimeVal    = NSAttributedString(string: "\(Int(totalGameTime))s", attributes: rightAlign)
        let aveGameTimeVal      = NSAttributedString(string: "\(Int(aveGameTime))s", attributes: rightAlign)
        let totalScoreVal       = NSAttributedString(string: "\(Int(totalScore))", attributes: rightAlign)
        let aveScoreEasyVal     = NSAttributedString(string: "\(Int(averageScoreEasy))", attributes: rightAlign)
        let aveScoreHardVal     = NSAttributedString(string: "\(Int(averageScoreHard))", attributes: rightAlign)
        let totalGamesVal       = NSAttributedString(string: "\(Int(totalGames))", attributes: rightAlign)
        
        let totalGameTimeStr    = NSAttributedString(string: "\nTotal Game Time\n", attributes: regular)
        let aveGameTimeStr      = NSAttributedString(string: "\nAverage Game Time\n", attributes: regular)
        let totalScoreStr       = NSAttributedString(string: "Total Goals Scored\n", attributes: regular)
        let aveScoreEasyStr     = NSAttributedString(string: "\nAverage Score (Easy)\n", attributes: regular)
        let aveScoreHardStr     = NSAttributedString(string: "\nAverage Score (Hard)\n", attributes: regular)
        let totalGamesStr       = NSAttributedString(string: "\nTotal Games Played\n", attributes: regular)
        
        let statsString = NSMutableAttributedString()
        statsString.append(totalScoreStr)
        statsString.append(totalScoreVal)
        
        statsString.append(aveScoreEasyStr)
        statsString.append(aveScoreEasyVal)
        
        statsString.append(aveScoreHardStr)
        statsString.append(aveScoreHardVal)
        
        statsString.append(totalGameTimeStr)
        statsString.append(totalGameTimeVal)
        
        statsString.append(aveGameTimeStr)
        statsString.append(aveGameTimeVal)
        
        statsString.append(totalGamesStr)
        statsString.append(totalGamesVal)
        
        self.statsLabel.attributedText = statsString
    }
}
