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
    private var time = 0.0
    private var red = 0.0
    private var green = 1.0
    private let MAX_TIME = 1.0
    
    private var touchDownTime = 0.0
    private var touchUpTime = 0.0

    private var throwing = false
    
    public func initTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            self.time = self.time + 0.01
            if self.throwing {
                self.currentTime = CFAbsoluteTimeGetCurrent() - self.touchDownTime
                self.setColor()
            }
        }
    }
    public func touchDown() {
        self.throwing = true
        self.touchDownTime = CFAbsoluteTimeGetCurrent()
    }
    
    public func touchUp() {
        self.throwing = false
        self.touchUpTime = CFAbsoluteTimeGetCurrent()
    }
    
    public func getTime() -> Double {
        var touchTime = self.touchUpTime - self.touchDownTime
        if touchTime > MAX_TIME {
            touchTime = MAX_TIME
        }
        resetTime()
        return touchTime
    }
    
    private func resetTime() {
        self.currentTime = 0.0
        self.progressColor = Color(red: 0, green: 1, blue: 0)
        self.red = 0.0
        self.green = 1.0
    }
    
    private func setColor() {
        if (self.currentTime < (self.MAX_TIME/2)) {
            self.red = self.currentTime * 2
        } else {
            self.green = (self.MAX_TIME - self.currentTime) * 2
        }
        self.progressColor = Color(red: self.red, green: self.green, blue: 0)
    }
}
