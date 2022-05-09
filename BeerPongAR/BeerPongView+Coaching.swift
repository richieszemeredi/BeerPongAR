//
//  BeerPongView+Coaching.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 21..
//

import ARKit

extension BeerPongView: ARCoachingOverlayViewDelegate {
    /// Sets the `gameController`s coaching variable to true when coaching will happen.
    public func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        self.gameController.coaching = true
    }
    
    /// Sets the `gameController`s coaching variable to false when coaching will happen.
    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        self.gameController.coaching = false
    }
}
