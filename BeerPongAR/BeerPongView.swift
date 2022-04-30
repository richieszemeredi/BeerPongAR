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
                self.gameController.objectsPlaced = true
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
        self.gameController.throwingEnabled = false
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
        ballEntity.addForce([0,0.01,-force], relativeTo: camera)
        
        self.collisionSubscribing = scene.subscribe(
            to: CollisionEvents.Began.self,
            on: ballEntity
        ) { event in
            let table = self.gameController.gameAnchor.table
            let hitEntity = event.entityB
            if hitEntity.name.contains("cup") {
                print(hitEntity.position(relativeTo: table))
                if hitEntity.position(relativeTo: table).y > 50 {
                    hitEntity.isEnabled = false
                    print("\(hitEntity.name) removed")
                    event.entityA.removeFromParent()
                    self.gameController.cupDown()
                    camera.removeFromParent()
                    self.gameController.throwingEnabled = true
                }
            }
        }
        self.collisionSubscribing = scene.subscribe(
            to: CollisionEvents.Updated.self,
            on: ballEntity
        ) { event in
            let table = self.gameController.gameAnchor.table
            let hitEntity = event.entityB
            if hitEntity.name.contains("cup") {
                if hitEntity.position(relativeTo: table).y > 50 {
                    hitEntity.isEnabled = false
                    print("\(hitEntity.name) removed")
                    event.entityA.removeFromParent()
                    self.gameController.cupDown()
                    camera.removeFromParent()
                    self.gameController.throwingEnabled = true
                }
            }
        }
        self.collisionSubscribing = scene.subscribe(
            to: CollisionEvents.Ended.self,
            on: ballEntity
        ) { event in
            let table = self.gameController.gameAnchor.table
            let hitEntity = event.entityB
            if hitEntity.name.contains("cup") {
                if hitEntity.position(relativeTo: table).y > 50 {
                    hitEntity.isEnabled = false
                    print("\(hitEntity.name) removed")
                    event.entityA.removeFromParent()
                    self.gameController.cupDown()
                    camera.removeFromParent()
                    self.gameController.throwingEnabled = true
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if !self.gameController.throwingEnabled {
                camera.removeFromParent()
                self.gameController.throwingEnabled = true
                
            }
        }
    }
    
    
    @objc
    func handleTap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gameController.appState == .gamePlaying && self.gameController.throwingEnabled && !self.gameController.coaching {
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
}
