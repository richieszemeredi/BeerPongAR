//
//  GameController.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 05..
//

import Foundation
import RealityKit
import SwiftUI
import CoreData
    
class GameController: ObservableObject {
    @Environment(\.managedObjectContext) private var persistenceControllerContext

    @Published var gameTimeSeconds = 0.0

    var gameStart = Date()
    var gameAnchor: GameExperience.Game!
    var cupNumber = 6
    var gamePlaying = true
    var timer = Timer()
        
    func cupDown(atTime: Double) {
        if self.cupNumber > 1 {
            self.cupNumber -= 1
        } else {
            saveScore()
        }
    }
    
    func saveScore() {
        @Environment(\.managedObjectContext) var context
        let score = HighScore(context: persistenceControllerContext)
        
        score.date = Date()
        score.seconds = self.gameTimeSeconds
        
        try? persistenceControllerContext.save()
    }
    
    func startGame() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.gameTimeSeconds += 0.1
            print(self.gameTimeSeconds)
        }
        gamePlaying = true
    }
    
    func pauseGame() {
        self.timer.invalidate()
        gamePlaying = false
    }
    
    func exitGame() {
        
    }
    
}


extension GameExperience.Game {
    var allCups: [Entity?] {
        return [
            player1cup1,
            player1cup2,
            player1cup3,
            player1cup4,
            player1cup5,
            player1cup6,
        ]
    }
}

extension CupTester.Game {
    var allCups: [Entity?] {
        return [
            cup
        ]
    }
}
