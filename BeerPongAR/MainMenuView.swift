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
            VStack {
            Text("🍻 BeerPong AR 🍺")
                .fixedSize(horizontal: false, vertical: true)
                .font(.largeTitle)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
                .foregroundColor(.white)
            }.padding(.top)
            Spacer()
            VStack{
                Button("Start game") {
                    gameController.selectLevel()
                }
                .disabled(!gameController.objectsPlaced)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
                .foregroundColor(.white)
                
                Button("Highscores") {
                    showHighScores.toggle()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
                .foregroundColor(.white)
            }
            .padding(50)
            .frame(maxWidth: 250)
        }
        .padding()
        .sheet(isPresented: $showHighScores) {
            HighScoresView()
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainMenuView(gameController: GameController())
        }
    }
}
