//
//  BluetoothManager.swift
//  electricityBot
//
//  Created by Dana Litvak on 16.07.2025.
//

import Foundation
import CoreBluetooth
import Combine

class BluetoothManager: NSObject, ObservableObject {
    
    static let shared = BluetoothManager()
    
    private var centralManager: CBCentralManager!
    @Published var peripherals: [CBPeripheral] = []
    @Published var statusMessage: String = ""
    
    private var targetPeripheral: CBPeripheral?
    private var ssidChar: CBCharacteristic?
    private var statusChar: CBCharacteristic?
    private var passChar: CBCharacteristic?
    private var scannedChar: CBCharacteristic?
    
    let serviceUUID = CBUUID(string: "a1ddeaf4-cfd8-4a7c-aa8d-ac18df3f8740")
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func scan() {
        peripherals = []
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
    
    func connect(to peripheral: CBPeripheral) {
        centralManager.stopScan()
        targetPeripheral = peripheral
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }
    
    func send(ssid: String, password: String) {
        guard let ssidChar = ssidChar, let passChar = passChar, let peripheral = targetPeripheral else { return }
        peripheral.writeValue(Data(ssid.utf8), for: ssidChar, type: .withResponse)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            peripheral.writeValue(Data(password.utf8), for: passChar, type: .withResponse)
        }
    }
    
    func fetchNetworks() {
        guard let scannedChar = scannedChar, let peripheral = targetPeripheral else { return }
        peripheral.readValue(for: scannedChar)
    }
}


extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is ON")
        } else {
            print("Bluetooth is unavailable.")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            peripherals.append(peripheral)
        }
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([serviceUUID])
    }
}


extension BluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        for char in service.characteristics ?? [] {
            switch char.uuid.uuidString.lowercased() {
            case "a1ddeaf4-cfd8-4a7c-aa8d-ac18df3f8741":
                ssidChar = char
            case "a1ddeaf4-cfd8-4a7c-aa8d-ac18df3f8743":
                statusChar = char
            case "a1ddeaf4-cfd8-4a7c-aa8d-ac18df3f8742":
                passChar = char
            case "a1ddeaf4-cfd8-4a7c-aa8d-ac18df3f8744":
                scannedChar = char
            default: break
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        guard let value = characteristic.value else { return }
        if characteristic == statusChar {
            statusMessage = String(decoding: value, as: UTF8.self)
        }
    }
}
