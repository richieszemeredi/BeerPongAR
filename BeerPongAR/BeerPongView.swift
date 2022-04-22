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
    
    init(frame: CGRect, gameController: GameController, throwTap: BallThrowTap) {
        self.gameController = gameController
        self.throwTap = throwTap
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
    var throwTap: BallThrowTap
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
        if !self.gameController.throwingDisabled {
            self.gameController.throwingDisabled = true
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
            ballEntity.addForce([0,(force*(-0.5)),force], relativeTo: camera)
            
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: resetAfterThrow)
        }
    }
    
    func resetAfterThrow() {
        gameController.gameAnchor.notifications.reposition.post()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            self.gameController.throwingDisabled = false
        }
    }
    
    @objc
    func handleTap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            throwTap.touchDown()
        } else if gestureRecognizer.state == .ended {
            throwTap.touchUp()
            var ballForce = Float(throwTap.currentTime * -0.125)
            if (ballForce > 2) {
                ballForce = 2
            }
            throwBall(force: ballForce)
            throwTap.reset()
        }
    }
}
