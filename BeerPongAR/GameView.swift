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
    @State var game: GameExperience.GameController
    @State var playerOnePoints: Int
    @State var playerTwoPoints: Int
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(
                ballThrowed: self.$ballThrowed,
                withTable: self.$withTable,
                multiplayer: self.$multiplayer,
                throwingDown: self.$throwingDown,
                throwingUp: self.$throwingUp,
                game: self.$game,
                playerOnePoints: self.$playerOnePoints
            ).edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Spacer()
                    Button("Exit", action: exitGame)
                }
                VStack {
                    Text("Points").font(.title).foregroundColor(.white).padding(5)
                    HStack(alignment: .top, content: {
                        Text("Player 1: \(self.playerOnePoints)")
                            .foregroundColor(.white)
                            .padding(.leading, 30)
                        Spacer()
                        Text("Player 2: \(self.playerTwoPoints)")
                            .foregroundColor(.white)
                            .padding(.trailing, 30)
                    }).padding(.bottom, 10)
                }.background(Color.white.opacity(0.5)).cornerRadius(25)
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
        
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var ballThrowed: Bool
    @Binding var withTable: Bool
    @Binding var multiplayer: Bool
    @Binding var throwingDown: Double
    @Binding var throwingUp: Double
    @Binding var game: GameExperience.GameController
    @Binding var playerOnePoints: Int
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let session = arView.session
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        session.run(config)
        
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = session
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
        
        arView.debugOptions = [.showFeaturePoints, .showPhysics]
        if (!multiplayer && withTable) {
            self.game.gameAnchor = try! GameExperience.loadGame()
            arView.scene.anchors.append(self.game.gameAnchor)
        } else if (!multiplayer && !withTable) {
            self.game.gameAnchor = try! GameExperience.loadGame()
            arView.scene.anchors.append(self.game.gameAnchor)
        } else if (multiplayer && withTable) {
            self.game.gameAnchor = try! GameExperience.loadGame()
            arView.scene.anchors.append(self.game.gameAnchor)
        } else if (multiplayer && !withTable) {
            self.game.gameAnchor = try! GameExperience.loadGame()
            arView.scene.anchors.append(self.game.gameAnchor)
        }
        game.start()
        return arView
    }
    
    func updateUIView(_ arView: ARView, context: Context) {
        let ball = createBallEntity().clone(recursive: true)
        let cameraAnchor = AnchorEntity(.camera)
        
        
        collisionSubscribing = arView.scene.subscribe(
            to: CollisionEvents.Began.self,
            on: ball
        ) { event in
            let hitEntity = event.entityB ?? ModelEntity()
            if hitEntity.name.contains("cup") {
                if (
                    event.position[0] < 2 &&
                    event.position[0] > -2 &&
                    event.position[1] > 4 &&
                    event.position[2] < 2 &&
                    event.position[2] > -2
                ) {
                    print("got in the middle \(hitEntity.name)")
                }
            }
        }
        
        
        if self.ballThrowed {
            arView.scene.addAnchor(cameraAnchor)
            cameraAnchor.addChild(ball)
            throwBall(ball: ball, fromPosition: cameraAnchor)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                game.throwed()
                resetCups()
                cameraAnchor.removeFromParent()
            }
        }
    }
    
    func createBallEntity() -> ModelEntity {
        let ball = MeshResource.generateSphere(radius: 0.038)
        let ballEntity = ModelEntity(mesh: ball, materials: [SimpleMaterial(color: .white, isMetallic: false)])
        let sphereShape = ShapeResource.generateSphere(radius: 0.038)
        ballEntity.collision = CollisionComponent(shapes: [sphereShape])
        ballEntity.physicsBody = PhysicsBodyComponent(
            massProperties: .init(shape: sphereShape, mass: /*0.0025*/ 0.0025),
            material: .default,
            mode: .dynamic
        )
        print("Created new ball entity.")
        return ballEntity
    }
    
    func throwBall(ball: ModelEntity, fromPosition: AnchorEntity) {
        var ballForce = Float((self.throwingUp - self.throwingDown) * -0.25)
        if (ballForce > 100) {
            ballForce = 100
        }
        
        ball.addForce([0,(ballForce*(-0.5)),ballForce], relativeTo: fromPosition)
        print("Thrown ball with \(ballForce*(-1)) force.")
    }
    
    func resetCups() {
        print("Reseting cups.")
        game.gameAnchor.notifications.reposition.post()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            self.ballThrowed = false
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
            game: GameExperience.GameController(players: 1),
            playerOnePoints: 0,
            playerTwoPoints: 0
        )
    }
}
#endif
