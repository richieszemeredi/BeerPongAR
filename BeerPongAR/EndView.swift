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
            VStack {
            Text("Game Over")
                .font(.largeTitle)
                .padding()
                .foregroundColor(.primary)
                .background(.ultraThinMaterial)
                .cornerRadius(10)
            }.padding(.top)
            Spacer()
            HStack {
                Text("Seconds:")
                    .padding()
                    .font(.title2)
                Text("\(String(format: "%.1f", self.gameController.gameSeconds))")
                    .padding()
                    .font(.largeTitle)
            }
            .padding()
            .foregroundColor(.primary)
            .background(.ultraThinMaterial)
            .cornerRadius(10)
            Spacer()
            VStack {
                Button("Start again") {
                    gameController.startGame()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.primary)
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                
                Button("Choose another level") {
                    gameController.selectLevel()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.primary)
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                
                Button ("Go to main menu") {
                    gameController.showMainMenu()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.primary)
                .background(.ultraThinMaterial)
                .cornerRadius(10)
            }
            .fixedSize(horizontal: true, vertical: false)
        }.padding()
    }
}

struct EndView_Previews: PreviewProvider {
    static var previews: some View {
        EndView(gameController: GameController())
    }
}
