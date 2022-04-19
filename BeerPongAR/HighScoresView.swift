//
//  HighScoresView.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 15..
//

import SwiftUI
import CoreData

struct HighScoresView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: HighScore.entity(), sortDescriptors: [])

    var highScores: FetchedResults<HighScore>
    
    var body: some View {
        VStack {
            HStack {
                Text("High Scores").font(.title).padding(10)
                Spacer()
            }
            List {
                ForEach(highScores) { highScore in
                    HStack {
                        Text("\(highScore.date?.formatted() ?? "Date error")")
                        Spacer()
                        Text("\(highScore.seconds)")
                    }.frame(height: 50)
                }
            }.padding(10).listStyle(.plain)
        }
    }
}

struct HighScoresView_Previews: PreviewProvider {
    static var previews: some View {
        HighScoresView()
    }
}
