//
//  EndView.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 22..
//

import SwiftUI

struct EndView: View {
    @ObservedObject var gameController: GameController
    
    var body: some View {
        VStack {
            Spacer()
            Text("Game Over")
                .padding()
                .font(.largeTitle)
                .background(Color.black.opacity(0.5))
                .cornerRadius(5)
                .foregroundColor(.white)
            HStack {
                Text("Seconds:").padding()
                Text("\(String(format: "%.1f", self.gameController.gameSeconds))").padding()
            }
            .padding()
            .font(.title3)
            .background(Color.black.opacity(0.5))
            .cornerRadius(5)
            .foregroundColor(.white)
            Spacer()
            HStack {
                Button("Start again") {
                    gameController.startGame()
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(5)
                .foregroundColor(.white)
                
                
                Button ("Go to main menu") {
                    gameController.appState = .mainMenu
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(5)
                .foregroundColor(.white)
            }.padding()
        }.padding()
    }
}

struct EndView_Previews: PreviewProvider {
    static var previews: some View {
        EndView(gameController: GameController())
    }
}
