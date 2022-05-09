//
//  HighScoresView.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 15..
//

import SwiftUI
import CoreData

struct HighScoresView: View {
    @Environment (\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @SectionedFetchRequest<String?, HighScore>(
        sectionIdentifier: \.level,
        sortDescriptors: [SortDescriptor(\.seconds, order: .forward)]
    )
    private var highScores: SectionedFetchResults<String?, HighScore>
    
    var body: some View {
        NavigationView {
            VStack {
                List(highScores) { section in
                    Section(header: Text(section.id?.capitalized ?? "uncategorised")) {
                        ForEach(section) { record in
                            HStack {
                                Text(record.date?.formatted() ?? "Bad date")
                                Spacer()
                                Text(String(format: "%.1f", record.seconds))
                            }
                        }
                        .onDelete { indexSet in
                            deleteScore(section: Array(section), offsets: indexSet)
                        }
                    }
                }.listStyle(.sidebar)
            }
            .navigationBarTitle(Text("High Scores"), displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    func deleteScore(section: [HighScore], offsets: IndexSet) {
        for index in offsets {
            let score = section[index]
            viewContext.delete(score)
        }
        try? viewContext.save()
    }
}

struct HighScoresView_Previews: PreviewProvider {
    static var previews: some View {
        HighScoresView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
