//
//  MainMenuView.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 03. 27..
//

import SwiftUI

struct MainMenuView: View {
    @ObservedObject var gameController: GameController
    @State var showHighScores = false
    
    var body: some View {
        VStack {
            Text("BeerPongAR")
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(5)
                .foregroundColor(.white)
            Spacer()
            VStack{
                Button("Start game") {
                    gameController.selectLevel()
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(5)
                .foregroundColor(.white)
                
                Button("Highscores") {
                    showHighScores.toggle()
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(5)
                .foregroundColor(.white)
            }.padding(50)
        }
        .padding()
        .sheet(isPresented: $showHighScores) {
            HighScoresView()
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView(gameController: GameController())
    }
}
