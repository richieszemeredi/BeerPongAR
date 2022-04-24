//
//  EndView.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 22..
//

import SwiftUI

struct EndView: View {
    @Environment(\.managedObjectContext) private var persistenceControllerContext

    @Binding var showEnd: Bool
    var gameController: GameController
    
    init(showEnd: Binding<Bool>, _ gameController: GameController) {
        self._showEnd = showEnd
        self.gameController = gameController
        
        let score = HighScore(context: persistenceControllerContext)
        score.date = Date()
        score.seconds = gameController.timer?.seconds ?? 0
        score.id = UUID()
        do {
            try persistenceControllerContext.save()
            print("Score saved.")
        } catch {
            print("Error saving context: \(error)")
        }

    }
    
    var body: some View {
        VStack {
            Text(self.gameController.timer?.seconds == 0.0 ? "Better luck next time!": "Congratulations!").font(.title).padding()
            HStack {
                Text("Seconds:").padding()
                Text("\(String(format: "%.1f", self.gameController.timer?.seconds ?? 0.0))").padding()
            }
            Button("Start Again") {
                gameController.resetGame()
                gameController.gameEnd = false
            }.padding()
            NavigationLink("Go to main menu", destination: MainMenuView()).padding()
        }
        .navigationBarHidden(true)
        .navigationTitle("")
    }
}

//struct EndView_Previews: PreviewProvider {
//    static var previews: some View {
//        EndView(GameController())
//    }
//}
