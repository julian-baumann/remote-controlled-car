//
//  CarModelView.swift
//  RemoteCarSteering
//
//  Created by Julian Baumann on 29.03.23.
//

import SwiftUI
import SceneKit

struct CarModelView: UIViewRepresentable {
    @Binding var rotation: Double
    
    @State var cameraNode = SCNNode()
    @State var scene = SCNScene.init(named: "OldCar.usdz")
    @State var modelNode: SCNNode?

    func makeUIView(context: Context) -> SCNView {
        cameraNode.camera = SCNCamera()
        scene?.rootNode.addChildNode(cameraNode)

        cameraNode.position = SCNVector3(x: 0, y: 900, z: 1000)
        cameraNode.camera?.zFar = 10000
        cameraNode.eulerAngles.x = 5.5
        
        let view = SCNView()
        view.allowsCameraControl = true
        view.isTemporalAntialiasingEnabled = true
        view.autoenablesDefaultLighting = true
        view.antialiasingMode = .multisampling4X
        view.scene = scene
        view.backgroundColor = .systemBackground
        
        return view;
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        var rotation = ((self.rotation) * 1.50) / 100
        rotation = Double(round(rotation * 1000) / 1000)
        let rootNode = scene?.rootNode.childNode(withName: "root", recursively: true)
        
        guard let rootNode = rootNode else {
            return;
        }
        
//        let transform = rootNode.transform
//        var translationX = SCNMatrix4MakeRotation(2, 10, 10, 10)
//        var xTranslation = SCNMatrix4MakeTranslation(0, 0, 0);
//
//        rootNode.transform = newTransform
        
//        let animation = CABasicAnimation(keyPath: "rotation")
//        animation.fillMode = .forwards;
//        let end = SCNVector4(0, 0, rotation, rotation)
//
//        animation.duration = 0.1
//        animation.byValue = end
//
//
//        rootNode.addAnimation(animation, forKey: "Rotate")
        
        print(rotation)
        
//        var action = SCNAction.rotateBy(x: 0, y: 0, z: CGFloat(rotation), duration: 0.1)
        
//        var action = SCNAction.rotate(by: rotation, around: SCNVector3(x: 0, y: 0, z: 0), duration: 0.1)
//
//        action.timingMode = .easeInEaseOut
//        rootNode.runAction(action)

        rootNode.eulerAngles.y = Float(rotation)
//        rootNode.runAction(SCNAction.rotateBy(x: 0, y: 0, z: rotation, duration: 0.2))

    }
}

struct CarModelView_Previews: PreviewProvider {
    @State static var test = -77.0
    
    static var previews: some View {
        CarModelView(rotation: $test)
    }
}

