//
//  Game.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 15..
//

import Foundation

class Game {
    var toShotPlayer: Int
    var players: [Player]
    
    init(players: Int) {
        self.players = []
        for _ in 0...players {
            let player = Player()
            self.players.append(player)
        }
        print("\(players) players created.")
        self.toShotPlayer = 1
    }
}
