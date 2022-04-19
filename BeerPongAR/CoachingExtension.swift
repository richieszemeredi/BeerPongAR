//
//  CoachingExtension.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 19..
//

import ARKit

extension ARCoachingOverlayView: ARCoachingOverlayViewDelegate {
    public func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) { }

    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) { }
    
    public func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) { }
}


class CustomCoachingOverlayView: ARCoachingOverlayView {
//    var coaching = true
//    
//    override func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
//        print("Coaching overlay activating.")
//        coaching = true
//    }
//    
//    override func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
//        print("Coaching overlay deactiveating.")
//        coaching = false
//    }
    
}
