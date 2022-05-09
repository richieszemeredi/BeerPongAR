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
        self.collisionSubscribing = []
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
    var collisionSubscribing: [Cancellable?]
    
    private func setupWorldTracking() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        session.run(config)
//        self.debugOptions = [.showFeaturePoints, .showPhysics, .showAnchorGeometry, .showWorldOrigin, .showAnchorOrigins, .showSceneUnderstanding]
        
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
                print("Couldn't load game scene")
            }
        })
    }
    
    func setup() {
        setupWorldTracking()
        loadGameScene()
        gameController.throwTap.initTimer()
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
        
        self.collisionSubscribing.append(scene.subscribe(
            to: CollisionEvents.Began.self,
            on: ballEntity
        ) { event in
            let table = self.gameController.gameAnchor.table
            let hitEntity = event.entityB
            if hitEntity.name.contains("cup") {
                let dst = self.distanceBetweenEntities(ballEntity, and: table!)
                if dst[1] > 0.9 {
                    hitEntity.isEnabled = false
                    event.entityA.removeFromParent()
                    self.gameController.cupDown()
                    ballEntity.removeFromParent()
                    camera.removeFromParent()
                    self.gameController.throwingEnabled = true
                    self.collisionSubscribing.removeAll()
                }
            }
        })
        
        self.collisionSubscribing.append(scene.subscribe(
            to: CollisionEvents.Updated.self,
            on: ballEntity
        ) { event in
            let table = self.gameController.gameAnchor.table
            let hitEntity = event.entityB
            if hitEntity.name.contains("cup") {
                let dst = self.distanceBetweenEntities(ballEntity, and: table!)
                if dst[1] > 0.9 {
                    hitEntity.isEnabled = false
                    event.entityA.removeFromParent()
                    self.gameController.cupDown()
                    camera.removeFromParent()
                    self.gameController.throwingEnabled = true
                    self.collisionSubscribing.removeAll()
                }
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if !self.gameController.throwingEnabled {
                self.collisionSubscribing.removeAll()
                ballEntity.removeFromParent()
                camera.removeFromParent()
                self.gameController.throwingEnabled = true
            }
        }
    }
    
    private func distanceBetweenEntities(_ aEntity: Entity, and bEntity: Entity) -> SIMD3<Float> {
        let a = aEntity.position(relativeTo: nil)
        let b = bEntity.position(relativeTo: nil)
        var distance: SIMD3<Float> = [0, 0, 0]
        distance.x = abs(a.x - b.x)
        distance.y = abs(a.y - b.y)
        distance.z = abs(a.z - b.z)
        return distance
    }
        
    @objc
    func handleTap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gameController.appState == .gamePlaying && self.gameController.throwingEnabled && !self.gameController.coaching {
            if gestureRecognizer.state == .began {
                gameController.throwTap.touchDown()
            }
            if gestureRecognizer.state == .ended {
                var ballForce = Float(gameController.throwTap.getTimeReset() * 0.35)
                if (ballForce > 1) {
                    ballForce = 1
                }
                if (ballForce > 0.1){
                    throwBall(force: ballForce)
                }
            }
        }
    }
}
