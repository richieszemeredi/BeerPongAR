//
//  ContentView.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 24..
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var gameController = GameController()

    var body: some View {
        ZStack {
            ARViewContainer(gameController: gameController)
                .edgesIgnoringSafeArea(.all)
            
            if gameController.appState == .mainMenu {
                MainMenuView(gameController: gameController)
            }

            if gameController.appState == .gamePlaying {
                GameView(gameController: gameController)
            }

            if gameController.appState == .gameEnd {
                EndView(gameController: gameController)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
