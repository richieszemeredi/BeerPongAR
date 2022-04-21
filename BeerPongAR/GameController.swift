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
    
    var gameStart = Date()
    var gameAnchor: GameExperience.Game!
    var cupNumber = 6
    
    var throwingDisabled = false
    var timer: GameTimer?
    
    @Published var gamePlaying = false
    
    func cupDown() {
        if self.cupNumber > 1 {
            self.cupNumber -= 1
        } else {
            saveScore(gameSeconds: self.timer?.seconds ?? 0.0)
        }
    }
    
    func saveScore(gameSeconds: Double) {
        @Environment(\.managedObjectContext) var context
        let score = HighScore(context: persistenceControllerContext)
        
        score.date = Date()
        score.seconds = gameSeconds
        
        try? persistenceControllerContext.save()
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
