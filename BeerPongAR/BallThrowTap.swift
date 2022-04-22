//
//  BallThrowTap.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 21..
//

import Foundation
import SwiftUI

class BallThrowTap: ObservableObject {
    @Published var currentTime = 0.0
    @Published var progressColor = Color(red: 0, green: 1, blue: 0)
    private var timer = Timer()
    private var red = 0.0
    private var green = 1.0
    private let MAX_TIME = 2.0
    
    public func touchDown() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            self.currentTime = self.currentTime + 0.01
            self.setColor()
            if self.currentTime >= self.MAX_TIME {
                self.timer.invalidate()
            }
        }
    }
    
    public func touchUp() {
        self.timer.invalidate()
    }

    public func reset() {
        self.currentTime = 0.0
        self.progressColor = Color(red: 0, green: 1, blue: 0)
        self.red = 0.0
        self.green = 1.0
        self.timer.invalidate()
    }
    
    private func setColor() {
        print("Current time: \(self.currentTime)")
        if (self.currentTime < (self.MAX_TIME/2)) {
            self.red = self.currentTime * 2
        } else {
            self.green = (self.MAX_TIME - self.currentTime) * 2
        }
        self.progressColor = Color(red: self.red, green: self.green, blue: 0)
    }
}
