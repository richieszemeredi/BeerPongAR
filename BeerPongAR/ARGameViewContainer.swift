//
//  ARGameViewContainer.swift
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
    @Binding var gameController: GameController
    
    @Binding var ballThrowed: Bool
    @Binding var throwingDown: Double
    @Binding var throwingUp: Double
    
    let coachingOverlay = CustomCoachingOverlayView()
    
    func makeUIView(context: Context) -> ARView {
        UIApplication.shared.isIdleTimerDisabled = true

        let arView = ARView(frame: .zero)
        let session = arView.session
        let config = ARWorldTrackingConfiguration()
        config.isCollaborationEnabled = true
        config.planeDetection = [.horizontal]
        session.run(config)
        
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        arView.addSubview(coachingOverlay)
        coachingOverlay.delegate = coachingOverlay
        arView.debugOptions = [.showFeaturePoints, .showPhysics, .showAnchorGeometry, .showWorldOrigin, .showAnchorOrigins, .showSceneUnderstanding]
        gameController.gameAnchor = try! GameExperience.loadGame()
        arView.scene.anchors.append(gameController.gameAnchor)

        return arView
    }
    
    func updateUIView(_ arView: ARView, context: Context) {
        if coachingOverlay.isHidden {
            if !gameController.gamePlaying {
                gameController.startGame()
            }
        }
        
        if coachingOverlay.isActive {
            if gameController.gamePlaying {
                gameController.pauseGame()
            }
        }
        let ball = createBallEntity().clone(recursive: true)
        let cameraAnchor = AnchorEntity(.camera)
        collisionSubscribing = arView.scene.subscribe(
            to: CollisionEvents.Began.self,
            on: ball
        ) { event in
            let hitEntity = event.entityB
            if hitEntity.name.contains("cup") {
                hitEntity.removeFromParent()
                print("\(hitEntity.name) removed")
                event.entityA.removeFromParent()
                gameController.cupDown(atTime: gameController.gameTimeSeconds)
            }
        }
        
        if (self.ballThrowed) {
            arView.scene.addAnchor(cameraAnchor)
            cameraAnchor.addChild(ball)
            throwBall(ball: ball, fromPosition: cameraAnchor)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
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
