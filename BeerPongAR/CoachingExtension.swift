//
//  CoachingExtension.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 19..
//

import ARKit
import Combine

extension ARCoachingOverlayView: ARCoachingOverlayViewDelegate {
    public func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) { }

    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) { }
    
    public func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) { }
}


class CustomCoachingOverlayView: ARCoachingOverlayView, ObservableObject {
    @Published var coaching = false
    
    override func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        print("Coaching overlay activating.")
        self.coaching = true
    }
    
    override func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        print("Coaching overlay deactiveating.")
        self.coaching = false
    }
}
