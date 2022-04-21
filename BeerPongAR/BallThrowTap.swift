//
//  BallThrowTap.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 21..
//

import Foundation

class BallThrowTap {
    private var touchDownTime = CFAbsoluteTime(0)
    private var touchUpTime = CFAbsoluteTime(0)
    
    public func touchDown() {
        self.touchDownTime = CFAbsoluteTimeGetCurrent()
    }
    
    public func touchUp() {
        self.touchUpTime = CFAbsoluteTimeGetCurrent()
    }
    
    public func getTime() -> Double {
        return (self.touchUpTime - self.touchDownTime)
    }
}
