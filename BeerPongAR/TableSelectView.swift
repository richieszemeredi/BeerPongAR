//
//  TableSelectView.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 05..
//

import SwiftUI

struct TableSelectView: View {
    @State var multiplayer: Bool
    
    var body: some View {
            ZStack {
                    VStack{
                        NavigationLink("Have a table to play on", destination: GameView(withTable: false, multiplayer: false, throwingDown: CFAbsoluteTime(0), throwingUp: CFAbsoluteTime(0), game: GameController(players: 1)))
                            .padding(10)
                            .navigationBarTitle("")
                            .navigationBarHidden(false)
                        
                        NavigationLink("Don't have a table to play on", destination: GameView(withTable: true, multiplayer: false, throwingDown: CFAbsoluteTime(0), throwingUp: CFAbsoluteTime(0), game: GameController(players: 1)))
                            .padding(10)
                            .navigationBarTitle("")
                            .navigationBarHidden(false)
                    }.padding(50)
            }
        }
    }


struct TableSelectView_Previews: PreviewProvider {
    static var previews: some View {
        TableSelectView(multiplayer: false)
    }
}
