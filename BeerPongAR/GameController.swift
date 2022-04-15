//
//  GameController.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 05..
//

import Foundation

class GameController {
    var pointsPlayer1: Int
    var pointsPlayer2: Int
    var players: Int
    var cupShot: Int
    var onGamePlayer: Int
    
    
    init(players: Int) {
        self.players = players
        self.pointsPlayer1 = 0
        self.pointsPlayer2 = 0
        self.cupShot = 0
        self.onGamePlayer = 0
    }
    
    public func start() {
        self.onGamePlayer = 1
        print("game started")
    }
}
