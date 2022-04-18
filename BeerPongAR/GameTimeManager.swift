//
//  GameTimeManager.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 17..
//

import Foundation
import SwiftUI

class GameTimeManager: ObservableObject {

    @Published var secondsElapsed = 0.0
    var timer = Timer()
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            self.secondsElapsed += 0.1
        }
    }
}
