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

        let easyScores = storage.localLeaderboardEasy
        let hardScores = storage.localLeaderboardHard
        
        var easyGameTimes:[Double] = []
        var hardGameTimes:[Double] = []
        var easyGameTimeSum = 0.0
        var hardGameTimeSum = 0.0
        var easyScoresSum = 0
        var hardScoresSum = 0
        
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
        
        let totalGames = easyGameTimes.count + hardGameTimes.count
        
        // Total Game Time
        let totalGameTime = easyGameTimeSum + hardGameTimeSum
        
        // Average Game Time
//        let aveGameTimeEasy = easyGameTimeSum / Double(easyGameTimes.count)
//        let aveGameTimeHard = hardGameTimeSum / Double(hardGameTimes.count)
        let aveGameTime = totalGames > 0 ? totalGameTime / Double(totalGames) : 0

        // Total Score
        let totalScore = easyScoresSum + hardScoresSum
        
        // Average Score
        let averageScoreEasy = easyGameTimes.count > 0 ? Double(easyScoresSum) / Double(easyGameTimes.count) : 0
        let averageScoreHard = hardGameTimes.count > 0 ? Double(hardScoresSum) / Double(hardGameTimes.count) : 0
        
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
        
        
        let totalGameTimeVal = NSAttributedString(string: "\(Int(totalGameTime))s", attributes: rightAlign)
        let aveGameTimeVal = NSAttributedString(string: "\(Int(aveGameTime))s", attributes: rightAlign)
        let totalScoreVal = NSAttributedString(string: "\(Int(totalScore))", attributes: rightAlign)
        let aveScoreEasyVal = NSAttributedString(string: "\(Int(averageScoreEasy))", attributes: rightAlign)
        let aveScoreHardVal = NSAttributedString(string: "\(Int(averageScoreHard))", attributes: rightAlign)
        
        let totalGameTimeStr    = NSAttributedString(string: "\nTotal Game Time\n", attributes: regular)
        let aveGameTimeStr      = NSAttributedString(string: "\nAverage Game Time\n", attributes: regular)
        let totalScoreStr       = NSAttributedString(string: "Total Goals Scored\n", attributes: regular)
        let aveScoreEasyStr     = NSAttributedString(string: "\nAverage Score (Easy)\n", attributes: regular)
        let aveScoreHardStr     = NSAttributedString(string: "\nAverage Score (Hard)\n", attributes: regular)
        
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
        
        self.statsLabel.attributedText = statsString
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
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
    
    func calculate(difficulty: GameDifficulty, level: Int) -> (Double, Int) {
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
            let (spawnSpeed, numberOfLevels) = calculate(difficulty: difficulty, level: level)
            let levelsToRemove = score < numberOfLevels ? score : numberOfLevels
            
            gameTime += spawnSpeed * Double(levelsToRemove)
            score -= levelsToRemove
            level += 1
        }
        
        return gameTime
    }
    
    // MARK: Actions
    
    @IBAction func closeTapped(_ sender: Any) {
        self.coordinator.showIntroView()
    }
}
