//
//  MainMenuView.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 03. 27..
//

import SwiftUI

struct MainMenuView: View {
    @State var showHighScores = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Text("BeerPongAR").font(.system(size: 50)).padding(50)
                    Spacer()
                    VStack{
                        NavigationLink("Start Game", destination: GameView())
                            .padding(10).font(.headline)
                        
                        Button( action: {
                            showHighScores = true
                        }) {
                            Text("HighScores")
                        }.padding(10).font(.headline)
                          
                    }.padding(50)
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        .popover(isPresented: $showHighScores) {
            HighScoresView()
        }
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
