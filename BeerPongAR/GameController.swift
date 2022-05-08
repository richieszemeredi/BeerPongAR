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
    case levelSelecting
    case gamePlaying
    case gameEnd
}

enum GameLevel {
    case easy
    case medium
    case hard
}
    
class GameController: ObservableObject {
    let moc = PersistenceController.shared.container.viewContext

    @Published var appState: AppState = .mainMenu
    @Published var gameSeconds = 0.0
    @Published var gameLevel: GameLevel = .easy
    @Published var objectsPlaced = false
    @Published var throwingEnabled = false

    var throwTap = BallThrowTap()
    var gameTimer = Timer()
    var gamePlaying = false
    var gameAnchor: GameExperience.Game!
    var cupNumber = 6
    var coaching = false
    
    func selectLevel() {
        self.throwingEnabled = false
        self.appState = .levelSelecting
        self.gamePlaying = false
        self.gameAnchor.notifications.resetToDefault.post()
    }
    
    func initTimer() {
        self.gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if (self.gamePlaying && !self.coaching && self.objectsPlaced) {
                self.gameSeconds = self.gameSeconds + 0.1
            }
        }
    }
    
    func startGame() {
        switch self.gameLevel {
        case .easy:
            self.gameAnchor.notifications.positionEasyLevel.post()
            break
        case .medium:
            self.gameAnchor.notifications.positionMediumLevel.post()
            break
        case .hard:
            self.gameAnchor.notifications.positionHardLevel.post()
            break
        }
        self.cupNumber = 6
        self.appState = .gamePlaying
        self.gameSeconds = 0.0
        self.gameAnchor.notifications.revealCups.post()
        self.gameAnchor.notifications.revealTable.post()
        self.throwingEnabled = true
        self.gamePlaying = true
    }
    
    func pauseGame() {
        self.throwingEnabled = false
        self.gamePlaying = false
    }
    
    func resumeGame() {
        self.throwingEnabled = true
        self.gamePlaying = true
    }
    
    func endGame() {
        self.throwingEnabled = false
        self.gamePlaying = false
        self.appState = .gameEnd
        self.gameAnchor.notifications.resetToDefault.post()
        self.gameAnchor.notifications.hideTable.post()
        let highScore = HighScore(context: moc)
        highScore.date = Date()
        highScore.id = UUID()
        highScore.seconds = gameSeconds
        highScore.level = "\(self.gameLevel)"
        try? moc.save()
    }
    
    func showMainMenu() {
        self.gameAnchor.notifications.hideCups.post()
        self.gameAnchor.notifications.hideTable.post()
        self.gameAnchor.notifications.resetToDefault.post()
        self.throwingEnabled = false
        self.gamePlaying = false
        self.appState = .mainMenu
    }
    
    func cupDown() {
        if self.cupNumber > 1 {
            self.cupNumber -= 1
        } else {
           endGame()
        }
    }
}


extension GameExperience.Game {
    var allCups: [Entity?] {
        return [
            cup1,
            cup2,
            cup3,
            cup4,
            cup5,
            cup6,
            table
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
