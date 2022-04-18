//
//  GameViewContainer.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 18..
//

import Foundation
import SwiftUI
import RealityKit
import ARKit
import Combine

var collisionSubscribing:Cancellable?

struct ARGameViewContainer: UIViewRepresentable {
    @Binding var ballThrowed: Bool
    @Binding var throwingDown: Double
    @Binding var throwingUp: Double
    @Binding var gameController: GameController
    
    var gameTimeManager: GameTimeManager
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let session = arView.session
        let config = ARWorldTrackingConfiguration()
        config.isCollaborationEnabled = true
        config.planeDetection = [.horizontal]
        session.run(config)
        
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = session
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
        
//        arView.debugOptions = [.showFeaturePoints, .showPhysics]
        gameController.gameAnchor = try! GameExperience.loadGame()
        arView.scene.anchors.append(gameController.gameAnchor)
        
//        if !multiplayer {
//            gameController.gameAnchor.notifications.showOnePlayer.post()
//        }
        gameController.start()
        gameTimeManager.start()
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
                
                let positionOfBallOnCup = event.entityA.position(relativeTo: hitEntity)
                
                print("---------------------------------")
                print(event.entityA.position(relativeTo: hitEntity))
                print(hitEntity.position(relativeTo: event.entityA))

                print("---------------------------------")
                
                if positionOfBallOnCup[1] > 0.32 {
                    hitEntity.removeFromParent()
                }

//                let pos = hitEntity.position
//                print(hitEntity.position)
//                print(hitEntity.position(relativeTo: gameController.gameAnchor.table))
                
//                if (
//                    pos[0] < 1 &&
//                    pos[0] > -1 &&
//                    pos[1] < 0.92 &&
//                    pos[1] > 0.90 &&
//                    pos[2] < 1 &&
//                    pos[2] > -1
//                ) {
//                    hitEntity.removeFromParent()
//                    print("\(hitEntity.name) removed")
//                    event.entityA.removeFromParent()
//                    resetCups()
//                }
                
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
