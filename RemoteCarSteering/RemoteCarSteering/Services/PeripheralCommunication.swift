//
//  PeripheralCommunicationService.swift
//  OpenPhyboxSwift
//
//  Created by Julian Baumann on 19.02.23.
//

import Foundation
import CoreBluetooth

enum Rotation: Int {
    case none = 0
    case left = 1
    case right = 2
}

enum AccelerationDirection: Int {
    case none = 0
    case forward = 1
    case backward = 2
}

class PeripheralCommunication: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    public static let shared = PeripheralCommunication()
    
    private let serviceUUID = CBUUID(string: "B742662E-6D94-43BD-B257-8077D259EE5E")
    private let rotationCharacteristicUUID = CBUUID(string: "16623586-A80C-4092-8042-652F934B8167")
    private let accelerationCharacteristicUUID = CBUUID(string: "D4C3EA03-F05A-41B2-B8AA-B5C8DB0ACD26")
    
    private var centralManager: CBCentralManager!
    private var peripheralESP: CBPeripheral?
    private var count = 0
    
    private var rotationCharacteristic: CBCharacteristic?
    private var accelerationCharacteristic: CBCharacteristic?
    
    private var lastAccelerationState: AccelerationDirection = .none
    
    @Published public var isPoweredOn = false
    @Published public var connected = false
    @Published public var connecting = false
    @Published public var connectedPeripheral: CBPeripheral?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    }
    
    public func changeAcceleration(direction: AccelerationDirection) {
        guard let accelerationCharacteristic = self.accelerationCharacteristic else {
            return
        }
        
        if lastAccelerationState == direction {
            return
        }
        
        lastAccelerationState = direction
        
        var stateAsInteger = direction.rawValue
        let stateData = Data(bytes: &stateAsInteger, count: MemoryLayout.size(ofValue: stateAsInteger))
        
        connectedPeripheral?.writeValue(stateData, for: accelerationCharacteristic, type: .withResponse)
    }
    
    public func changeRotation(rotation: Int) {
        guard let rotationCharacteristic = self.rotationCharacteristic else {
            return
        }
        
        var mutableRotation = rotation
        let directionData = Data(bytes: &mutableRotation, count: MemoryLayout.size(ofValue: mutableRotation))
        
        connectedPeripheral?.writeValue(directionData, for: rotationCharacteristic, type: .withResponse)
    }
    
    func startScanning() {
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if connectedPeripheral == nil {
            connectedPeripheral = peripheral
            connecting = true
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        centralManager.stopScan()
        connected = true
        connecting = false
        connectedPeripheral?.delegate = self
        connectedPeripheral?.discoverServices([serviceUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if (error != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let services = peripheral.services else {
            return
        }
        
        for service in services {
            peripheral.discoverCharacteristics([rotationCharacteristicUUID, accelerationCharacteristicUUID], for: service)
        }
        
        print("Discovered Services: \(services)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if (error != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        for characteristic in characteristics {
            if characteristic.uuid == rotationCharacteristicUUID {
                rotationCharacteristic = characteristic
            }
            else if characteristic.uuid == accelerationCharacteristicUUID {
                accelerationCharacteristic = characteristic
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectedPeripheral = nil
        print(error ?? "Failed to connect to device")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connected = false
        connectedPeripheral = nil
        startScanning()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isPoweredOn = true
            startScanning()
        }
        else {
            isPoweredOn = false
        }
    }
}
