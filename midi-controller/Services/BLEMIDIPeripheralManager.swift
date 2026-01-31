//
//  BLEMIDIPeripheralManager.swift
//  midi-controller
//

import CoreBluetooth
import Foundation

/// Represents a connected BLE central device
struct ConnectedDevice: Identifiable {
    let id: UUID
    var shortIdentifier: String {
        String(id.uuidString.prefix(8))
    }
}

/// Delegate protocol for BLE MIDI peripheral state changes
protocol BLEMIDIPeripheralManagerDelegate: AnyObject {
    func peripheralManagerDidUpdateState(_ state: CBManagerState)
    func peripheralManagerDidStartAdvertising(_ error: Error?)
    func peripheralManagerDidConnect(_ device: ConnectedDevice)
    func peripheralManagerDidDisconnect(_ device: ConnectedDevice)
}

/// Manages BLE MIDI peripheral advertising and MIDI message transmission
final class BLEMIDIPeripheralManager: NSObject {

    // BLE MIDI Service and Characteristic UUIDs (standard)
    private static let midiServiceUUID = CBUUID(string: "03B80E5A-EDE8-4B33-A751-6CE34EC4C700")
    private static let midiCharacteristicUUID = CBUUID(string: "7772E5DB-3868-4112-A1A9-F2669D106BF3")

    weak var delegate: BLEMIDIPeripheralManagerDelegate?

    private var peripheralManager: CBPeripheralManager?
    private var midiCharacteristic: CBMutableCharacteristic?
    private var connectedCentrals: [UUID: CBCentral] = [:]
    private var shouldStartAdvertising = false

    var bluetoothState: CBManagerState {
        peripheralManager?.state ?? .unknown
    }

    var isAdvertising: Bool {
        peripheralManager?.isAdvertising ?? false
    }

    var isConnected: Bool {
        !connectedCentrals.isEmpty
    }

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    /// Starts advertising as a BLE MIDI peripheral
    func startAdvertising() {
        guard let peripheralManager, peripheralManager.state == .poweredOn else { return }

        // Create MIDI characteristic with required properties
        midiCharacteristic = CBMutableCharacteristic(
            type: Self.midiCharacteristicUUID,
            properties: [.read, .writeWithoutResponse, .notify],
            value: nil,
            permissions: [.readable, .writeable]
        )

        // Create MIDI service
        let midiService = CBMutableService(type: Self.midiServiceUUID, primary: true)
        midiService.characteristics = [midiCharacteristic!]

        // Mark that we want to advertise after service is added
        shouldStartAdvertising = true
        peripheralManager.add(midiService)
    }

    private func beginAdvertising() {
        guard let peripheralManager else { return }
        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [Self.midiServiceUUID],
            CBAdvertisementDataLocalNameKey: "MIDI Controller"
        ])
    }

    /// Stops advertising
    func stopAdvertising() {
        shouldStartAdvertising = false
        peripheralManager?.stopAdvertising()
        peripheralManager?.removeAllServices()
        connectedCentrals.removeAll()
        midiCharacteristic = nil
    }

    /// Sends a MIDI message to all connected centrals
    /// - Parameter data: BLE MIDI formatted data
    func sendMIDIMessage(_ data: Data) {
        guard let peripheralManager,
              let characteristic = midiCharacteristic,
              !connectedCentrals.isEmpty else { return }

        let centrals = Array(connectedCentrals.values)
        peripheralManager.updateValue(data, for: characteristic, onSubscribedCentrals: centrals)
    }
}

// MARK: - CBPeripheralManagerDelegate

extension BLEMIDIPeripheralManager: CBPeripheralManagerDelegate {

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        delegate?.peripheralManagerDidUpdateState(peripheral.state)
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        delegate?.peripheralManagerDidStartAdvertising(error)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if error == nil && shouldStartAdvertising {
            beginAdvertising()
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        // Respond to read requests with empty data (required for BLE MIDI)
        request.value = Data()
        peripheral.respond(to: request, withResult: .success)
    }

    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        central: CBCentral,
        didSubscribeTo characteristic: CBCharacteristic
    ) {
        connectedCentrals[central.identifier] = central
        let device = ConnectedDevice(id: central.identifier)
        delegate?.peripheralManagerDidConnect(device)
    }

    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        central: CBCentral,
        didUnsubscribeFrom characteristic: CBCharacteristic
    ) {
        if connectedCentrals.removeValue(forKey: central.identifier) != nil {
            let device = ConnectedDevice(id: central.identifier)
            delegate?.peripheralManagerDidDisconnect(device)
        }
    }
}
