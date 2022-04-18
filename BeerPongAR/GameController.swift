//
//  GameController.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 05..
//

import Foundation
import RealityKit


protocol GameControllerObserver: AnyObject {
    func gameController(_ gameController: GameController)
}


    
class GameController {
    var player: Player
    var gameStart: NSDate
    var gameAnchor: GameExperience.Game!
    
    
    init(gameStart: NSDate) {
        self.player = Player()
        self.gameStart = gameStart
    }
    
    public func start() {
        print("Game started.")
    }
    
    
    public func throwed() {
        
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
        ]
    }
}
