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
    @State var gameController = GameController()
    
    @State var ballThrowing = false
    @State var ballThrowed = false
    @State var throwingDown = CFAbsoluteTimeGetCurrent()
    @State var throwingUp = CFAbsoluteTimeGetCurrent()
    @State var exitGameAlert = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARGameViewContainer(
                gameController: self.$gameController,
                ballThrowed: self.$ballThrowed,
                throwingDown: self.$throwingDown,
                throwingUp: self.$throwingUp
            ).edgesIgnoringSafeArea(.all)
            VStack {
                HStack(alignment: .top, content: {
                    VStack {
                        Text("Time elapsed")
                            .foregroundColor(.white)
                            .padding(5)
                        Text(String(format: "%.1f", gameController.gameTimeSeconds))
                            .foregroundColor(.white)
                            .padding(5)
                            .font(.system(size: 40))
                    }.background(Color.black.opacity(0.5)).cornerRadius(5)
                    Spacer()
                    Button("Exit") {
                        exitGameAlert = true
                        gameController.pauseGame()
                    }
                    .padding(5)
                    .buttonStyle(.bordered)
                    .alert(isPresented: $exitGameAlert) {
                        Alert(
                            title: Text("Do you really want to exit?"),
                            message: Text("This will end the game."),
                            primaryButton: .cancel(
                                Text("No"),
                                action: { gameController.startGame() }
                            ),
                            secondaryButton: .destructive(
                                Text("Yes"),
                                action: exitGame
                            )
                        )
                    }
                })
                Spacer()
                Button( action: {
                    self.throwingUp = CFAbsoluteTimeGetCurrent()
                    self.ballThrowed = true
                    self.ballThrowing = false
                }) {
                    Text("Hold to throw")
                }
                .padding(20).buttonStyle(.bordered)
                .simultaneousGesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged({_ in
                        if !self.ballThrowed {
                            if !self.ballThrowing {
                                self.throwingDown = CFAbsoluteTimeGetCurrent()
                                self.ballThrowing = true
                            }
                        }
                    })
                ).disabled(self.ballThrowed)
            }.padding()
        }.navigationBarHidden(true).navigationBarTitle("")
    }
    
    func exitGame() {
        gameController.exitGame()
    }
}

#if DEBUG
struct GameView_Previews : PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
#endif
