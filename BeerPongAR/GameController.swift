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
    var gameStart = Date()
    var gameAnchor: GameExperience.Game!
    var cupNumber = 6
    
    var throwingDisabled = false
    var timer: GameTimer?
    @Published var gameEnd = false
    
    @Published var gamePlaying = false
    
    func cupDown() {
        print(self.timer?.seconds ?? "no timer")
        if self.cupNumber > 23 {
            self.cupNumber -= 1
        } else {
            timer?.timer.invalidate()
            self.gameEnd = true
        }
    }
    
    func exitGame() {
        
    }
    
    func resetGame() {
        
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
