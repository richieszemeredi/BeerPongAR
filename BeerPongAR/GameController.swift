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
    var cupCount = 6
    var coaching = false
    
    /// Decreases `cupCount` variable. When it reaches 1, ends the game
    /// by calling the `endGame` method.
    func cupDown() {
        if self.cupCount > 1 {
            self.cupCount -= 1
        } else {
            endGame()
        }
    }
    
    /// Ends the game. Switches the screen to the game end view.
    /// Saves the game score to the storage.
    func endGame() {
        pauseGame()
        self.appState = .gameEnd
        do {
            let highScore = HighScore(context: moc)
            highScore.date = Date()
            highScore.id = UUID()
            highScore.seconds = gameSeconds
            highScore.level = "\(self.gameLevel)"
            try moc.save()
        } catch let error {
            print(error)
        }
    }
    
    /// Initialises the game timer.
    /// When the game is playing, there's no coaching in progress and the objects are placed, increases the game seconds.
    func initTimer() {
        self.gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if (self.gamePlaying && !self.coaching && self.objectsPlaced) {
                self.gameSeconds = self.gameSeconds + 0.1
            }
        }
    }
    
    /// Pauses the game by disabling ball throwing, and hides the objects.
    func pauseGame() {
        self.throwingEnabled = false
        self.gamePlaying = false
        self.gameAnchor.notifications.hide.post()
    }
    
    /// Resumes the game by showing objects. When the objects on the screen, resumes the game timer.
    func resumeGame() {
        self.gameAnchor.notifications.show.post()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.throwingEnabled = true
            self.gamePlaying = true
        }
    }
    
    /// Sets the screen on the level selecting view, and disables ball throwing, and stops the timer.
    func selectLevel() {
        self.throwingEnabled = false
        self.gamePlaying = false
        self.appState = .levelSelecting
    }
    
    /// Sets the screen on the main menu view.
    /// Disables ball throwing, and stops the timer.
    func showMainMenu() {
        self.throwingEnabled = false
        self.gamePlaying = false
        self.appState = .mainMenu
    }
    
    /// Starts a new game. Sets up the cup count, resets the timer, sets the screen on the game view.
    /// Sends a notification to the game anchor to position the cups depending on the game level.
    /// Reveals objects, and when the scene is set, starts the game, enables ball throwing.
    func startGame() {
        self.cupCount = 6
        self.gameSeconds = 0.0
        self.appState = .gamePlaying
        switch self.gameLevel {
        case .easy:
            self.gameAnchor.notifications.setupEasyLevel.post()
            break
        case .medium:
            self.gameAnchor.notifications.setupMediumLevel.post()
            break
        case .hard:
            self.gameAnchor.notifications.setupHardLevel.post()
            break
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.gameAnchor.notifications.show.post()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.throwingEnabled = true
            self.gamePlaying = true
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
