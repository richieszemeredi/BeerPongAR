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
        NavigationView {
            VStack {
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
            .navigationBarTitle(Text("High Scores"), displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct HighScoresView_Previews: PreviewProvider {
    static var previews: some View {
        HighScoresView()
    }
}
