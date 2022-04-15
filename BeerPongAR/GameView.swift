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

var collisionSubscribing:Cancellable?


struct GameView : View {
    @State var withTable: Bool
    @State var multiplayer: Bool
    @State private var gameTableTop = false
    @State var ballThrowing = false
    @State private var ballThrowed = false
    @State var throwingDown: CFAbsoluteTime
    @State var throwingUp: CFAbsoluteTime
    @State var game: GameController
    
    var body: some View {
        
        ZStack(alignment: .bottom) {
            ARViewContainer(ballThrowed: self.$ballThrowed, withTable: self.$withTable, multiplayer: self.$multiplayer, throwingDown: self.$throwingDown, throwingUp: self.$throwingUp, game: self.$game).edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Spacer()
                    Button("Exit", action: exitGame)
                }
                VStack {
                    Text("Points").font(.title).foregroundColor(.white).padding(5)
                    HStack(alignment: .top, content: {
                        Text("Player 1: \(self.game.pointsPlayer1)").foregroundColor(.white).padding(.leading, 30)
                        Spacer()
                        Text("Player 2: \(self.game.pointsPlayer2)").foregroundColor(.white).padding(.trailing, 30)
                    }).padding(.bottom, 10)
                }.background(Color.white.opacity(0.5)).cornerRadius(25)
                Spacer()
                Button( action: {
                    
                }) {
                    Text("Throw!")
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
                    .onEnded({_ in
                        self.throwingUp = CFAbsoluteTimeGetCurrent()
                        self.ballThrowed = true
                        self.ballThrowing = false
                    })
                )
            }.padding()
        }
    }
    
    func exitGame() {
        
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var ballThrowed: Bool
    @Binding var withTable: Bool
    @Binding var multiplayer: Bool
    @Binding var throwingDown: Double
    @Binding var throwingUp: Double
    @Binding var game: GameController
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let session = arView.session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        session.run(config)
        
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = session
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
        
        arView.debugOptions = [.showFeaturePoints, .showPhysics]
        if (!multiplayer && withTable) {
            let anchor = try! GameExperience.loadOnePlayerWithTable()
            arView.scene.anchors.append(anchor)
        } else if (!multiplayer && !withTable) {
            let anchor = try! GameExperience.loadOnePlayerWithoutTable()
            arView.scene.anchors.append(anchor)
        } else if (multiplayer && withTable) {
            let anchor = try! GameExperience.loadTwoPlayerWithTable()
            arView.scene.anchors.append(anchor)
        } else if (multiplayer && !withTable) {
            let anchor = try! GameExperience.loadTwoPlayerWithoutTable()
            arView.scene.anchors.append(anchor)
        }
        game.start()
        return arView
    }
    
    func updateUIView(_ arView: ARView, context: Context) {
        let ball = MeshResource.generateSphere(radius: 0.038)
        let ballEntity = ModelEntity(mesh: ball, materials: [SimpleMaterial(color: .white, isMetallic: false)])
        let sphereShape = ShapeResource.generateSphere(radius: 0.038)
        ballEntity.collision = CollisionComponent(shapes: [sphereShape])
        ballEntity.physicsBody = PhysicsBodyComponent(
            massProperties: .init(shape: sphereShape, mass: /*0.0025*/ 0.05),
            material: .default,
            mode: .dynamic
        )
    
        if self.ballThrowed {
            let cameraAnchor = AnchorEntity(.camera)
            arView.scene.addAnchor(cameraAnchor)

            let ballClone = ballEntity.clone(recursive: true)
            cameraAnchor.addChild(ballClone)

            var ballForce = (self.throwingUp - self.throwingDown) * 10
            if (ballForce > 100) {
                ballForce = 100
            }

            ballClone.addForce([0,2,Float((ballForce*(-1)))], relativeTo: cameraAnchor)
            collisionSubscribing = arView.scene.subscribe(
                to: CollisionEvents.Began.self,
                on: ballClone
            ) { event in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    cameraAnchor.removeFromParent()
                    ballClone.removeFromParent()
                    self.ballThrowed = false

                }
            }
        }
    }
}


#if DEBUG
struct GameView_Previews : PreviewProvider {
    static var previews: some View {
        GameView(
            withTable: false,
            multiplayer: false,
            throwingDown: CFAbsoluteTimeGetCurrent(),
            throwingUp: CFAbsoluteTimeGetCurrent(),
            game: GameController(players: 1)
        )
    }
}
#endif
