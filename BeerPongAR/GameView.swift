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
    @State var restartGameAlert = false
    @State var selectGameAlert = false
    
        var body: some View {
        ZStack {
            VStack {
                Spacer()
                Image("crosshair")
                    .resizable()
                    .frame(width: 50, height: 50, alignment: .center)
                    .colorMultiply(gameController.throwingEnabled ? .green : .red)
                Spacer()
            }
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
                
                .cornerRadius(10)
                
                HStack {
                    Button("Select level") {
                        selectGameAlert = true
                        gameController.pauseGame()
                    }
                    .alert(isPresented: $selectGameAlert) {
                        Alert(
                            title: Text("Would you like to exit?"),
                            message: Text("This will discard any of your game progress."),
                            primaryButton: .cancel(
                                Text("No"),
                                action: {
                                    gameController.resumeGame()
                                }
                            ),
                            secondaryButton: .destructive(
                                Text("Yes"),
                                action: {
                                    gameController.selectLevel()
                                }
                            )
                        )
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                        
                    Spacer()
                    
                    Button("Restart level") {
                        restartGameAlert = true
                        gameController.pauseGame()
                    }
                    .alert(isPresented: $restartGameAlert) {
                        Alert(
                            title: Text("Would you like to restart the game?"),
                            message: Text("This will discard any of your game progress."),
                            primaryButton: .cancel(
                                Text("No"),
                                action: {
                                    gameController.resumeGame()
                                }
                            ),
                            secondaryButton: .destructive(
                                Text("Yes"),
                                action: {
                                    gameController.startGame()
                                }
                            )
                        )
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                        
                    Spacer()
                    
                    Button("Exit") {
                        exitGameAlert = true
                        gameController.pauseGame()
                    }
                    .alert(isPresented: $exitGameAlert) {
                        Alert(
                            title: Text("Would you like to exit?"),
                            message: Text("This will discard any of your game progress."),
                            primaryButton: .cancel(
                                Text("No"),
                                action: {
                                    gameController.resumeGame()
                                }
                            ),
                            secondaryButton: .destructive(
                                Text("Yes"),
                                action: {
                                    gameController.showMainMenu()
                                }
                            )
                        )
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                        
                }
                Spacer()
                VStack {
                    ProgressView(value: gameController.throwTap.currentTime, total: 1.0)
                        .padding()
                        .opacity(gameController.throwTap.currentTime == 0.0 ? 0 : 1)
                        .progressViewStyle(LinearProgressViewStyle(tint: gameController.throwTap.progressColor))
                        .scaleEffect(x: 1, y: 4, anchor: .center)
                    Text("Press and hold the screen to throw a ball when the crosshair is green")
                        .multilineTextAlignment(.center)
                        .padding(5)
                        .foregroundColor(.white.opacity(0.5))
                        .opacity(gameController.gameSeconds < 10 ? 1 : 0)
                }
            }.padding()
        }
    }
}

#if DEBUG
struct GameView_Previews : PreviewProvider {
    static var previews: some View {
        GameView(gameController: GameController())
    }
}
#endif
