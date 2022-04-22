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
    @ObservedObject var gameTimer = GameTimer()
    @ObservedObject var throwTap = BallThrowTap()

    @ObservedObject private var gameController = GameController()
    
    @State var exitGameAlert = false
    @State var showEnd: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ARGameViewContainer(showEnd: self.$showEnd, gameController, gameTimer, throwTap)
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack(alignment: .top, content: {
                    HStack {
                        Text("Time elapsed")
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                        Text(String(format: "%.1f", gameTimer.seconds))
                            .foregroundColor(.white)
                            .padding()
                            .font(.system(size: 40))
                    }.background(Color.black.opacity(0.5)).cornerRadius(5)
                })
                HStack {
                    Button("Select level") {
                        
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(5)
                    .foregroundColor(.white)
                    Spacer()
                    Button("Exit") {
                        exitGameAlert = true
                        gameTimer.pause()
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(5)
                    .foregroundColor(.white)
                    .alert(isPresented: $exitGameAlert) {
                        Alert(
                            title: Text("Do you really want to exit?"),
                            message: Text("This will end the game."),
                            primaryButton: .cancel(
                                Text("No"),
                                action: {
                                    gameTimer.start()
                                }
                            ),
                            secondaryButton: .destructive(
                                Text("Yes"),
                                action: {
                                    exitGame()
                                }
                            )
                        )
                    }
                }
                Spacer()
            }.padding()
            VStack {
                ProgressView(value: throwTap.currentTime, total: 1.0)
                    .padding()
                    .opacity(throwTap.currentTime == 0.0 ? 0 : 1)
                    .progressViewStyle(LinearProgressViewStyle(tint: throwTap.progressColor))
                    .scaleEffect(x: 1, y: 4, anchor: .center)
                Text("Press and hold the screen to throw a ball").padding(5).foregroundColor(.white.opacity(0.5))
            }
            NavigationLink("endview", destination: EndView(showEnd: self.$showEnd, gameController), isActive: self.$gameController.gameEnd).hidden()
        }.navigationBarHidden(true).navigationBarTitle("")
    }
    
    func exitGame() {
        gameController.exitGame()
        gameController.gameEnd = true
    }
}

struct ARGameViewContainer: UIViewRepresentable {
    @ObservedObject var timer: GameTimer
    @ObservedObject var throwTap: BallThrowTap
    private var gameController: GameController
    
    @Binding var showEnd: Bool
    
    init(showEnd: Binding<Bool>, _ gameController: GameController, _ timer: GameTimer, _ throwTap: BallThrowTap) {
        self.gameController = gameController
        self.timer = timer
        self.throwTap = throwTap
        self._showEnd = showEnd
        gameController.timer = self.timer
    }
   
    func makeUIView(context: Context) -> BeerPongView {
        let arView = BeerPongView(frame: .zero, gameController: self.gameController, throwTap: self.throwTap)
        arView.setup()
        return arView
    }
    
    func updateUIView(_ arView: BeerPongView, context: Context) {
       
    }
    
}


#if DEBUG
struct GameView_Previews : PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
#endif
