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

enum AppState {
    case mainMenu
    case gamePlaying
    case gameEnd
}
    
class GameController: ObservableObject {
    @Published var appState: AppState = .mainMenu
    @Published var gameSeconds = 0.0
    
    var throwTap = BallThrowTap()
    var gameTimer = Timer()
    
    var gameStart = Date()
    var gameAnchor: GameExperience.Game!
    var cupNumber = 6
    
    func startGame() {
        self.appState = .gamePlaying
        self.gameSeconds = 0.0
        self.gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.gameSeconds = self.gameSeconds + 0.1
        }
        self.gameStart = Date()
    }
    
    func pauseGame() {
        self.gameTimer.invalidate()
    }
    
    func resumeGame() {
        self.gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.gameSeconds = self.gameSeconds + 0.1
        }
    }
    
    func endGame() {
        self.appState = .gameEnd
        self.gameTimer.invalidate()
    }
    
    func cupDown() {
        if self.cupNumber > 23 {
            self.cupNumber -= 1
        } else {
           endGame()
        }
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
