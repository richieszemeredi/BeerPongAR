//
//  BeerPongView.swift
//  BeerPongAR
//
//  Created by Richárd Szemerédi on 2022. 04. 21..
//

import ARKit
import Combine
import SwiftUI
import RealityKit

class BeerPongView: ARView, ARSessionDelegate {
    
    init(frame: CGRect, gameController: GameController) {
        self.gameController = gameController
        super.init(frame: frame)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    var arView: ARView { return self }
    var gameController: GameController
    var collisionSubscribing:Cancellable?


    private func setupWorldTracking() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        session.run(config)
        self.debugOptions = [.showFeaturePoints, .showPhysics, .showAnchorGeometry, .showWorldOrigin, .showAnchorOrigins, .showSceneUnderstanding]
        
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.delegate = self
        arView.addSubview(coachingOverlay)
    }
    
    private func loadGameScene() {
        GameExperience.loadGameAsync(completion: { (result) in
            do {
                self.gameController.gameAnchor = try result.get()
                self.scene.anchors.append(self.gameController.gameAnchor)
            } catch {
                fatalError("Couldn't load game scene")
            }
        })
    }
    
    func setup() {
        setupWorldTracking()
        loadGameScene()
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        tap.minimumPressDuration = 0
        addGestureRecognizer(tap)
    }
    
    func throwBall(force: Float) {
//        if !self.gameController.throwingDisabled {
//            self.gameController.throwingDisabled = true
            let ballMesh = MeshResource.generateSphere(radius: 0.038)
            let ballEntity = ModelEntity(mesh: ballMesh, materials: [SimpleMaterial(color: .white, isMetallic: false)])
            let sphereShape = ShapeResource.generateSphere(radius: 0.038)
            ballEntity.collision = CollisionComponent(shapes: [sphereShape])
            ballEntity.physicsBody = PhysicsBodyComponent(
                massProperties: .init(shape: sphereShape, mass: 0.0025),
                material: .default,
                mode: .dynamic
            )
            let camera = AnchorEntity(.camera)
            scene.addAnchor(camera)
            camera.addChild(ballEntity)
            ballEntity.addForce([0,(force*(0.5)),-force], relativeTo: camera)
            
            self.collisionSubscribing = scene.subscribe(
                to: CollisionEvents.Began.self,
                on: ballEntity
            ) { event in
                let hitEntity = event.entityB
                if hitEntity.name.contains("cup") {
                    hitEntity.removeFromParent()
                    print("\(hitEntity.name) removed")
                    event.entityA.removeFromParent()
                    self.gameController.cupDown()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.resetAfterThrow()
                camera.removeFromParent()
            }
//        }
    }
    
    func resetAfterThrow() {
        gameController.gameAnchor.notifications.reposition.post()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
//            self.gameController.throwingDisabled = false
        }
    }
    
    @objc
    func handleTap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            gameController.throwTap.touchDown()
        } else if gestureRecognizer.state == .ended {
            gameController.throwTap.touchUp()
            var ballForce = Float(gameController.throwTap.currentTime * 0.25)
            if (ballForce > 1) {
                ballForce = 1
            }
            throwBall(force: ballForce)
            gameController.throwTap.reset()
        }
    }
}
