//
//  MainMenuView.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 03. 27..
//

import SwiftUI

struct MainMenuView: View {
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Text("BeerPongAR").font(.system(size: 50)).padding(50)
                    Spacer()
                    VStack{
                        NavigationLink("Singleplayer", destination: GameView(
                            multiplayer: false, gameController: GameExperience.GameController()
                        ))
                            .padding(10).font(.headline)
                        NavigationLink("Multiplayer", destination: GameView(
                            multiplayer: true, gameController: GameExperience.GameController()
                        ))
                            .padding(10).font(.headline)
                        NavigationLink("Highscores", destination: HighScoresView())
                            .padding(10).font(.headline)
                    }.padding(50)
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
