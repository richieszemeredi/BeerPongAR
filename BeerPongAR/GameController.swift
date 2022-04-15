//
//  GameController.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 05..
//

import Foundation
import RealityKit


protocol GameControllerObserver: AnyObject {
    func gameController(_ gameController: GameExperience.GameController)
}


extension GameExperience {
    
    class GameController {
        var cupShot: Int = 0
        var withTable: Bool = false
        var players: [Player]
        var toShotPlayer: Int
        
        var gameAnchor: GameExperience.Game!
        
        
        init(players: Int) {
            self.players = []
            for _ in 0...players {
                let player = Player()
                self.players.append(player)
            }
            print("\(players) players created.")
            self.toShotPlayer = 1
            
        }
        
        public func start() {
            print("Game started.")
            self.toShotPlayer = 1
        }
        
        
        public func throwed() {
            if self.toShotPlayer == 1 {
                self.toShotPlayer = 2
            } else {
                self.toShotPlayer = 1
            }
            
            
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
            player1cup6
//            player2cup1,
//            player2cup2,
//            player2cup3,
//            player2cup4,
//            player2cup5,
//            player2cup6
        ]
    }
}
