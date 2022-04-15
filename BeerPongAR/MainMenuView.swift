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
                        NavigationLink("Singleplayer", destination: TableSelectView(multiplayer: false))
                            .padding(10)
                            .navigationBarTitle("")
                            .navigationBarHidden(true)
                        
                        NavigationLink("Multiplayer", destination: TableSelectView(multiplayer: true))
                            .padding(10)
                            .navigationBarTitle("")
                            .navigationBarHidden(true)
                    }.padding(50)
                }
                
            }
        }
        
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}
