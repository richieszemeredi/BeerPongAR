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
    
    let persistenceController = PersistenceController.shared
    
    var body: some View {
        VStack {
            VStack {
                Text("🍻 BeerPong AR 🍺")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.largeTitle)
                    .foregroundColor(.primary)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
            }
            .padding(.top)
            
            Spacer()
            
            VStack{
                Button("Start game") {
                    gameController.selectLevel()
                }
                .disabled(!gameController.objectsPlaced)
                .frame(maxWidth: .infinity)
                .foregroundColor(.primary)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                
                Button("Highscores") {
                    showHighScores.toggle()
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.primary)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(10)
            }
            .padding(50)
            .frame(maxWidth: 250)
        }
        .padding()
        .sheet(isPresented: $showHighScores) {
            HighScoresView().environment(
                \.managedObjectContext,
                 persistenceController.container.viewContext
            )
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
