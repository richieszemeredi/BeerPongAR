//
//  LevelSelectView.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 24..
//

import SwiftUI

struct LevelSelectView: View {
    @ObservedObject var gameController: GameController

    var body: some View {
        VStack{
            Button("Easy") {
                gameController.gameLevel = .easy
                gameController.startGame()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.black.opacity(0.5))
            .cornerRadius(5)
            .foregroundColor(.white)
            
            Button("Medium") {
                gameController.gameLevel = .medium
                gameController.startGame()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.black.opacity(0.5))
            .cornerRadius(5)
            .foregroundColor(.white)
            
            Button("Hard") {
                gameController.gameLevel = .hard
                gameController.startGame()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.black.opacity(0.5))
            .cornerRadius(5)
            .foregroundColor(.white)
        }
        .padding(50)
        .frame(maxWidth: 200)

    }
}

struct LevelSelectView_Previews: PreviewProvider {
    static var previews: some View {
        LevelSelectView(gameController: GameController())
    }
}
