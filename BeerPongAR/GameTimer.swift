//
//  GameTimer.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 20..
//

import Foundation

enum timerMode {
    case running
    case stopped
    case paused
}

class GameTimer: ObservableObject {
    @Published var mode: timerMode = .stopped
    @Published var seconds = 0.0
    
    var timer = Timer()
    
    func start() {
        mode = .running
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.seconds = self.seconds + 0.1
        }
    }
    
    func pause() {
        mode = .paused
        self.timer.invalidate()
    }
    
    func reset() {
        mode = .stopped
        self.timer.invalidate()
        self.seconds = 0.0
    }
}
