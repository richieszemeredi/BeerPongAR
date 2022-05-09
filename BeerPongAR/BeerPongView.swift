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
    var arView: ARView { return self }
    var collisionSubscribing: [Cancellable?]
    var gameController: GameController
    
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
    
    /// Calculates the distance between two entities.
    ///
    /// - Parameters:
    ///  - aEntity: the first entity
    ///  - bEntity: the second entity
    ///
    /// - Returns: the distance between the given entities
    private func distanceBetweenEntities(_ aEntity: Entity, and bEntity: Entity) -> SIMD3<Float> {
        let a = aEntity.position(relativeTo: nil)
        let b = bEntity.position(relativeTo: nil)
        var distance: SIMD3<Float> = [0, 0, 0]
        distance.x = abs(a.x - b.x)
        distance.y = abs(a.y - b.y)
        distance.z = abs(a.z - b.z)
        return distance
    }
    
    /// Handles tap interactions on the ARView.
    ///
    /// - Parameters:
    /// - gestureRecogniser: the gesture recogniser
    @objc
    private func handleTap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gameController.appState == .gamePlaying && self.gameController.throwingEnabled && !self.gameController.coaching {
            if gestureRecognizer.state == .began {
                gameController.throwTap.touchDown()
            }
            if gestureRecognizer.state == .ended {
                gameController.throwTap.touchUp()
                let tapTime = gameController.throwTap.getTime()
                if (tapTime >= 0.1 && tapTime <= 1) {
                    throwBall(force: Float(tapTime * 0.35))
                }
            }
        }
    }
    
    /// Loads the game scene, and appends it into the ARView.
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
    
    /// Throws a ball on the ARView.
    /// Creates a ball entity, gives it the force got in the `force` parameter.
    /// Adds collision detection to the created ball, and removes the ball when it touches a
    /// cup on it's top.
    /// If no cup was touched on top, removes the ball two seconds after throwing.
    ///
    /// - Parameters:
    /// - force: the force of the ball
    private func throwBall(force: Float) {
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
    
    /// Initialises the AR world, starts the game timer, and sets up the scene.
    func setup() {
        setupWorldTracking()
        loadGameScene()
        gameController.throwTap.initTimer()
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        tap.minimumPressDuration = 0
        addGestureRecognizer(tap)
    }
    
    /// Sets up world tracking. Adds a Coaching Overlay to the view.
    private func setupWorldTracking() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        session.run(config)
        
        self.debugOptions = [.showAnchorGeometry]
        self.renderOptions = [
            .disableFaceMesh,
            .disableMotionBlur,
            .disableCameraGrain,
            .disablePersonOcclusion
        ]
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.delegate = self
        arView.addSubview(coachingOverlay)
    }
}
