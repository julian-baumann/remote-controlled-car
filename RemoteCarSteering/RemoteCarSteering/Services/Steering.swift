//
//  Steering.swift
//  RemoteCarSteering
//
//  Created by Julian Baumann on 20.03.23.
//

import Foundation
import CoreMotion

class Steering: ObservableObject {
    public static let shared = Steering()
    
    private let motion = CMMotionManager()
    private var initialRotation: Double?
    private var normalizeNextMeasurement = true
    private let peripheralCommunication = PeripheralCommunication.shared
    
    @Published var rotation: Double = 0.0

    init() {
        if motion.isGyroAvailable {
            motion.startDeviceMotionUpdates()
            motion.startDeviceMotionUpdates(to: .current!) { _,_ in
                Task {
                    await self.getDeviceRotation()
                }
            }
            
            
            
//            motion.startDeviceMotionUpdates()
            
            
            
            motion.startDeviceMotionUpdates(to: .current!) { motion,_ in
                let rotation = motion?.attitude.yaw
            }

//            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
//                Task {
//                    await self.getDeviceRotation()
//                }
//            }
        }
    }
    
    func getDeviceRotation() async {
        guard let rotation = self.motion.deviceMotion?.attitude.yaw else {
            return
        }
        
        if self.normalizeNextMeasurement {
            self.initialRotation = rotation;
            self.normalizeNextMeasurement = false
        }
        
        guard let initialRotation = self.initialRotation else {
            return
        }
        
        let calculatedRotation = ((rotation - initialRotation) * 90) * -1
        
        if calculatedRotation > -100 && calculatedRotation < 100 {
            DispatchQueue.main.async {
                self.rotation = calculatedRotation
            }
        }
        
        self.adjustRemoteCarRotation()
    }
    
    public func normalizeRotation() {
        self.normalizeNextMeasurement = true
    }
    
    public func adjustRemoteCarRotation() {
        let positiveRotationValue = Int(round(self.rotation)) + 100
        peripheralCommunication.changeRotation(rotation: positiveRotationValue)
    }
}
