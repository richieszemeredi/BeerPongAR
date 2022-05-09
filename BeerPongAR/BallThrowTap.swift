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
    
    private let MAX_TIME = 1.0
    
    private var red = 0.0
    private var green = 1.0
    
    private var touchDownTime = 0.0
    private var touchUpTime = 0.0
    
    private var throwing = false
    
    /// Initialises the timer for the progress view.
    public func initTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if self.throwing {
                self.currentTime = CFAbsoluteTimeGetCurrent() - self.touchDownTime
                self.setColor()
            }
        }
    }
    
    /// Calculates the time of the tap. If the tap is bigger then the set maximum time, returns the maximum time.
    ///
    /// - Returns: time of the tap
    public func getTime() -> Double {
        var touchTime = self.touchUpTime - self.touchDownTime
        if touchTime >= MAX_TIME {
            touchTime = MAX_TIME
        }
        resetTime()
        return touchTime
    }
    
    /// Resets the time of throw, and color of the progress view.
    private func resetTime() {
        self.currentTime = 0.0
        self.progressColor = Color(red: 0, green: 1, blue: 0)
        self.red = 0.0
        self.green = 1.0
    }
    
    /// Sets the touch down time to the current time.
    public func touchDown() {
        self.throwing = true
        self.touchDownTime = CFAbsoluteTimeGetCurrent()
    }
    
    /// Sets the touch up time to the current time.
    public func touchUp() {
        self.throwing = false
        self.touchUpTime = CFAbsoluteTimeGetCurrent()
    }
    
    /// Sets the progress views color by calculating it from the current time.
    /// If the time is smaller then half of the maximum time, increases the red.
    /// If the time is bigger then half of the maximum time, decreases the green.
    /// With this, there will be a smooth transition from green through yellow to white.
    private func setColor() {
        if (self.currentTime < (self.MAX_TIME/2) && self.red <= 1) {
            self.red = self.currentTime * 2
        } else if (self.green >= 0) {
            self.green = (self.MAX_TIME - self.currentTime) * 2
        }
        self.progressColor = Color(red: self.red, green: self.green, blue: 0)
    }
}
