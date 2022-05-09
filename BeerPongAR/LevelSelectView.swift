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
            Spacer()
            
            Button("Easy") {
                gameController.gameLevel = .easy
                gameController.startGame()
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.primary)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            
            Button("Medium") {
                gameController.gameLevel = .medium
                gameController.startGame()
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.primary)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            
            Button("Hard") {
                gameController.gameLevel = .hard
                gameController.startGame()
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.primary)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            
            Spacer()
            
            Button("Main menu") {
                gameController.showMainMenu()
            }
            .frame(maxWidth: .infinity)
            .foregroundColor(.primary)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            
            Spacer()
        }
        .padding(50)
        .frame(maxWidth: 250)
    }
}

struct LevelSelectView_Previews: PreviewProvider {
    static var previews: some View {
        LevelSelectView(gameController: GameController())
    }
}
