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
    @Environment (\.presentationMode) var presentationMode

    @FetchRequest(entity: HighScore.entity(), sortDescriptors: [])

    var highScores: FetchedResults<HighScore>
    
    var body: some View {
        VStack {
            HStack {
                Text("High Scores").font(.headline).padding()
                Spacer()
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }.padding()
            }
            List {
                ForEach(highScores) { highScore in
                    HStack {
                        Text(highScore.date?.formatted() ?? "Date error")
                        Spacer()
                        Text("\(highScore.seconds)")
                    }.frame(height: 50)
                }
            }.listStyle(.plain)
        }
    }
}

struct HighScoresView_Previews: PreviewProvider {
    static var previews: some View {
        HighScoresView()
    }
}
