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
                .padding()
                .font(.largeTitle)
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
                .foregroundColor(.white)
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
            .background(Color.black.opacity(0.5))
            .cornerRadius(10)
            .foregroundColor(.white)
            Spacer()
            VStack {
                Button("Start again") {
                    gameController.startGame()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
                .foregroundColor(.white)
                
                Button("Choose another level") {
                    gameController.selectLevel()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
                .foregroundColor(.white)
                
                Button ("Go to main menu") {
                    gameController.showMainMenu()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
                .foregroundColor(.white)
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
