//
//  GameView.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 03. 13..
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct GameView : View {
    @ObservedObject var gameController: GameController

    @State var exitGameAlert = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Time elapsed")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                Spacer()
                Text(String(format: "%.1f", gameController.gameSeconds))
                    .foregroundColor(.white)
                    .padding()
                    .font(.largeTitle)
            }
            .background(Color.black.opacity(0.5))
           
            .cornerRadius(5)
            
            HStack {
                Button("Select level") {
                    exitGameAlert.toggle()
                    gameController.selectLevel()
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(5)
                .foregroundColor(.white)
//                .alert(isPresented: $exitGameAlert) {
//                    Alert(
//                        title: Text("Do you really want to do it?"),
//                        message: Text("This will end the game."),
//                        primaryButton: .cancel(
//                            Text("No"),
//                            action: {
//                                gameController.resumeGame()
//                            }
//                        ),
//                        secondaryButton: .destructive(
//                            Text("Yes"),
//                            action: {
//                                gameController.selectLevel()
//                            }
//                        )
//                    )
//                }
                Spacer()
                Button("Restart level") {
                    exitGameAlert.toggle()
                    gameController.startGame()
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(5)
                .foregroundColor(.white)
//                .alert(isPresented: $exitGameAlert) {
//                    Alert(
//                        title: Text("Do you really want to do it?"),
//                        message: Text("This will end the game."),
//                        primaryButton: .cancel(
//                            Text("No"),
//                            action: {
//                                gameController.resumeGame()
//                            }
//                        ),
//                        secondaryButton: .destructive(
//                            Text("Yes"),
//                            action: {
//                                gameController.startGame()
//                            }
//                        )
//                    )
//                }
                Spacer()
                Button("Exit") {
                    exitGameAlert.toggle()
                    gameController.showMainMenu()
                }
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(5)
                .foregroundColor(.white)
//                .alert(isPresented: $exitGameAlert) {
//                    Alert(
//                        title: Text("Do you really want to exit?"),
//                        message: Text("This will end the game."),
//                        primaryButton: .cancel(
//                            Text("No"),
//                            action: {
//                                gameController.resumeGame()
//                            }
//                        ),
//                        secondaryButton: .destructive(
//                            Text("Yes"),
//                            action: {
//                                gameController.showMainMenu()
//                            }
//                        )
//                    )
//                }
            }
            Spacer()
            VStack {
                ProgressView(value: gameController.throwTap.currentTime, total: 1.0)
                    .padding()
                    .opacity(gameController.throwTap.currentTime == 0.0 ? 0 : 1)
                    .progressViewStyle(LinearProgressViewStyle(tint: gameController.throwTap.progressColor))
                    .scaleEffect(x: 1, y: 4, anchor: .center)
                Text("Press and hold the screen to throw a ball")
                    .padding(5)
                    .foregroundColor(.white.opacity(0.5))
                    .opacity(gameController.gameSeconds < 10 ? 1 : 0)
            }
        }.padding()
    }
}

#if DEBUG
struct GameView_Previews : PreviewProvider {
    static var previews: some View {
        GameView(gameController: GameController())
    }
}
#endif
