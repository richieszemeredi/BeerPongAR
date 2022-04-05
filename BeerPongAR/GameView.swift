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
    @State private var gameTableTop = false
    @State private var ballThrowed = false
    
    var body: some View {
        ZStack(alignment: .bottom, content: {
            ARViewContainer(ballThrowed: self.$ballThrowed, withTable: self.$withTable).edgesIgnoringSafeArea(.all)
            
            Button(action: {
                self.ballThrowed = true
            }) {
                Text("Throw!")
            }.padding(20).buttonStyle(.bordered)
        })
        
    }
    func resetThrow() {
        self.ballThrowed = false
    }
    
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var ballThrowed: Bool
    @Binding var withTable: Bool
    
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
        
        if (withTable) {
            let anchor = try! OnePlayerWithTable.loadScene()
            arView.scene.anchors.append(anchor)
        } else {
            let anchor = try! OnePlayerWithoutTable.loadScene()
            arView.scene.anchors.append(anchor)
        }
        
        return arView
    }
    
    func updateUIView(_ arView: ARView, context: Context) {
        let ball = MeshResource.generateSphere(radius: 0.01)
        let ballEntity = ModelEntity(mesh: ball)
        
        //ballEntity.transform.translation = [0, 0, 0]
        let sphereShape = ShapeResource.generateSphere(radius: 0.01)
        ballEntity.collision = CollisionComponent(shapes: [sphereShape])
        ballEntity.physicsBody = PhysicsBodyComponent(
            massProperties: .init(shape: sphereShape, mass: 5),
            material: nil,
            mode: .dynamic
        )
        

        if (ballThrowed) {
            let cameraAnchor = AnchorEntity(.camera)
            arView.scene.addAnchor(cameraAnchor)
            let ballClone = ballEntity.clone(recursive: true)
            cameraAnchor.addChild(ballClone)
            ballClone.addForce([0,100,-100], relativeTo: nil)
            collisionSubscribing = arView.scene.subscribe(to: CollisionEvents.Began.self,
                                                          on: ballClone) { event in
                ballThrowed = false
            }
//            let planeMesh = MeshResource.generatePlane(width: 1, depth: 1)
//            let material = SimpleMaterial(color: .init(white: 1.0, alpha: 0.5), isMetallic: false)
//            let planeEntity = ModelEntity(mesh: planeMesh, materials: [material])
//            planeEntity.position = [0,0,0]
//            planeEntity.physicsBody = PhysicsBodyComponent(massProperties: .default, material: nil, mode: .static)
//            planeEntity.collision = CollisionComponent(shapes: [.generateBox(width: 1, height: 0.001, depth: 1)])
//            cameraAnchor.addChild(planeEntity)
            
//            ballEntity.addForce([0, 2, 0], relativeTo: nil)
//            ballEntity.addTorque([Float.random(in: 0 ... 0.4), Float.random(in: 0 ... 0.4), Float.random(in: 0 ... 0.4)], relativeTo: nil)
            
            
        }
        
        
    }
}


//#if DEBUG
//struct GameView_Previews : PreviewProvider {
//    static var previews: some View {
//        GameView(isNavigationBarHidden: true, withTable: false)
//    }
//}
//#endif
