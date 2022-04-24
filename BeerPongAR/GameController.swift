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
    @Published var appState: AppState = .mainMenu
    @Published var gameSeconds = 0.0
    @Published var gameLevel: GameLevel = .easy
    
    var throwTap = BallThrowTap()
    var gameTimer = Timer()
    
    var gameStart = Date()
    var gameAnchor: GameExperience.Game!
    var cupNumber = 6
    
    func selectLevel() {
        self.gameTimer.invalidate()
        self.appState = .levelSelecting
    }
    
    func startGame() {
        self.gameTimer.invalidate()
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
        self.gameStart = Date()
        self.appState = .gamePlaying
        self.gameSeconds = 0.0
        for cup in self.gameAnchor.allCups {
            cup?.isEnabled = true
        }
        self.gameAnchor.notifications.revealCups.post()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                self.gameSeconds = self.gameSeconds + 0.1
            }
        }
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
    
    func showMainMenu() {
        self.appState = .mainMenu
    }
    
    func cupDown() {
        if self.cupNumber > 1 {
            self.cupNumber -= 1
        } else {
           endGame()
        }
    }
    
//    func resetCups() {
//        switch self.gameLevel {
//        case .easy:
////            self.gameAnchor.notifications.repositionEasyLevel.post()
//            break
//        case .medium:
////            self.gameAnchor.notifications.repositionMediumLevel.post()
//            break
//        case .hard:
////            self.gameAnchor.notifications.repositionHardLevel.post()
////            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
////                self.gameAnchor.notifications.startHardLevel.post()
////            }
//            break
//        }
//    }
//
}


extension GameExperience.Game {
    var allCups: [Entity?] {
        return [
            cup1,
            cup2,
            cup3,
            cup4,
            cup5,
            cup6
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
