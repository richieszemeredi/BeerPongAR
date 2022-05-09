//
//  ARViewContainer.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 24..
//

import Foundation
import SwiftUI

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var gameController: GameController
    
    func makeUIView(context: Context) -> BeerPongView {
        let arView = BeerPongView(frame: .zero, gameController: gameController)
        arView.setup()
        gameController.initTimer()
        return arView
    }
    
    func updateUIView(_ arView: BeerPongView, context: Context) {
        
    }
}
