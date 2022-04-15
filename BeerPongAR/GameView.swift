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
    @State var multiplayer: Bool
    @State var gameController: GameExperience.GameController

    @State var ballThrowing = false
    @State var ballThrowed = false
    @State var throwingDown = CFAbsoluteTimeGetCurrent()
    @State var throwingUp = CFAbsoluteTimeGetCurrent()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(
                ballThrowed: self.$ballThrowed,
                multiplayer: self.$multiplayer,
                throwingDown: self.$throwingDown,
                throwingUp: self.$throwingUp,
                gameController: self.$gameController
            ).edgesIgnoringSafeArea(.all)
            VStack {
                HStack(alignment: .top, content: {
                    VStack {
                        Text("Time elapsed").foregroundColor(.white).padding(5)
                        Text("0:00").foregroundColor(.white).padding(5).font(.system(size: 40))
                    }.background(Color.black.opacity(0.5)).cornerRadius(5)
                    Spacer()
                    Button("Exit", action: exitGame).padding(5).buttonStyle(.bordered)
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
        
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var ballThrowed: Bool
    @Binding var multiplayer: Bool
    @Binding var throwingDown: Double
    @Binding var throwingUp: Double
    @Binding var gameController: GameExperience.GameController
    
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
        self.gameController.gameAnchor = try! GameExperience.loadGame()
        arView.scene.anchors.append(self.gameController.gameAnchor)
        
        if !self.multiplayer {
            self.gameController.gameAnchor.notifications.showOnePlayer.post()
        }
        gameController.start()
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
                hitEntity.removeFromParent()
                
            }
        }
        
        
        if (self.ballThrowed) {
            arView.scene.addAnchor(cameraAnchor)
            cameraAnchor.addChild(ball)
            throwBall(ball: ball, fromPosition: cameraAnchor)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                gameController.throwed()
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
            massProperties: .init(shape: sphereShape, mass: 0.0025),
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
        gameController.gameAnchor.notifications.reposition.post()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            self.ballThrowed = false
        }
    }
}


#if DEBUG
struct GameView_Previews : PreviewProvider {
    static var previews: some View {
        GameView(
            multiplayer: false,
            gameController: GameExperience.GameController()
        )
    }
}
#endif
