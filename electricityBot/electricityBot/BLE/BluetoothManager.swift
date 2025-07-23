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
    @Published var isConnected = false
    @Published var connectedPeripheral: CBPeripheral?
    @Published var status: BluetoothStatus = .idle
    @Published var availableNetworks: [String] = []
    @Published var deviceID: String? = nil
    @Published var userID: String? = nil
    
    private var targetPeripheral: CBPeripheral?
    private var ssidChar: CBCharacteristic?
    private var statusChar: CBCharacteristic?
    private var passChar: CBCharacteristic?
    private var scannedChar: CBCharacteristic?
    private var deviceIDchar: CBCharacteristic?
    
    let serviceUUID = CBUUID(string: "a1ddeaf4-cfd8-4a7c-aa8d-ac18df3f8740")
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func scan() {
        guard centralManager.state == .poweredOn else {
            print("Bluetooth not ready, can’t scan yet")
            status = .bluetoothOff
            return
        }
        peripherals = []
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        status = .scanning
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if self.peripherals.isEmpty {
                self.status = .notFound
                self.centralManager.stopScan()
            }
        }
    }
    
    func connect(to peripheral: CBPeripheral) {
        centralManager.stopScan()
        targetPeripheral = peripheral
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
        self.connectedPeripheral = peripheral
        status = .connected
    }
    
    func send(ssid: String, password: String) {
        guard let ssidChar = ssidChar, let passChar = passChar, let peripheral = targetPeripheral else { return }
        print("Writing SSID: \(ssid) to characteristic: \(ssidChar.uuid)")
        peripheral.writeValue(Data(ssid.utf8), for: ssidChar, type: .withResponse)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("Writing Password: \(password) to characteristic: \(passChar.uuid)")
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
        print("Connected to \(peripheral.name ?? "unknown")")
        isConnected = true
        
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
            print("Discovered characteristic: \(char.uuid) properties: \(char.properties)")
            
            switch char.uuid.uuidString.lowercased() {
            case "a1ddeaf4-cfd8-4a7c-aa8d-ac18df3f8741":
                ssidChar = char
            case "a1ddeaf4-cfd8-4a7c-aa8d-ac18df3f8743":
                statusChar = char
                peripheral.setNotifyValue(true, for: char)
            case "a1ddeaf4-cfd8-4a7c-aa8d-ac18df3f8742":
                passChar = char
            case "a1ddeaf4-cfd8-4a7c-aa8d-ac18df3f8744":
                scannedChar = char
            case "a1ddeaf4-cfd8-4a7c-aa8d-ac18df3f8745":
                deviceIDchar = char
            default: break
            }
        }
    }
    
    func handleStatusUpdate(_ data: Data) {
        if let statusString = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                self.statusMessage = statusString.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } else {
            print("Failed to decode status message from data: \(data)")
        }
    }

    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        guard let value = characteristic.value else { return }
        if characteristic == statusChar {
            statusMessage = String(decoding: value, as: UTF8.self)
        } else if characteristic == scannedChar {
            let networksString = String(decoding: value, as: UTF8.self)
            print("Networks received: \(networksString)")

            let networks = networksString
                .split(separator: ",")
                .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            
            DispatchQueue.main.async {
                self.availableNetworks = networks
            }
        } else if characteristic == deviceIDchar {
            let deviceID = String(decoding: value, as: UTF8.self)
            print("Device ID: \(deviceID)")
            self.deviceID = deviceID
            
            Task {
                do {
                    let result = try await SendDevice.sendDeviceToBackend(userID: userID ?? "", deviceID: deviceID)
                    // use it in push
                    UserDefaults.standard.set(deviceID, forKey: "currentDeviceID")
                } catch {
                    print("Error sending device info: \(error)")
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Write to \(characteristic.uuid) failed: \(error.localizedDescription)")
            return
        }
        print("Successfully wrote to \(characteristic.uuid)")
        if let deviceIDchar = deviceIDchar {
            print("Reading device ID...")
            peripheral.readValue(for: deviceIDchar)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            print("Disconnected from \(peripheral.name ?? "unknown") with error: \(error.localizedDescription)")
        } else {
            print("Disconnected from \(peripheral.name ?? "unknown")")
        }
        isConnected = false
    }
}

enum BluetoothStatus: Equatable {
    case idle
    case scanning
    case notFound
    case bluetoothOff
    case connected
    case error(String)
}
