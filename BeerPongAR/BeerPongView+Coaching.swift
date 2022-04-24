//
//  BeerPongView+Coaching.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 21..
//

import ARKit

extension BeerPongView: ARCoachingOverlayViewDelegate {
    public func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        if self.gameController.appState == .gamePlaying {
            self.gameController.pauseGame()
        }
    }
    
    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        if self.gameController.appState == .gamePlaying {
            self.gameController.resumeGame()
        }
    }
}
