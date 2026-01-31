//
//  BLEMIDIViewModel.swift
//  midi-controller
//

import CoreBluetooth
import Foundation
import SwiftUI

/// ViewModel that bridges BLE MIDI manager to SwiftUI
@Observable
@MainActor
final class BLEMIDIViewModel {

    private(set) var isAdvertising = false
    private(set) var isConnected = false
    private(set) var bluetoothState: CBManagerState = .unknown

    var ccValue: Double = 0 {
        didSet {
            sendControlChange()
        }
    }

    private let bleManager: BLEMIDIPeripheralManager

    var isBluetoothReady: Bool {
        bluetoothState == .poweredOn
    }

    var statusText: String {
        switch bluetoothState {
        case .poweredOn:
            if isConnected {
                return "Connected"
            } else if isAdvertising {
                return "Advertising..."
            } else {
                return "Ready"
            }
        case .poweredOff:
            return "Bluetooth Off"
        case .unauthorized:
            return "Unauthorized"
        case .unsupported:
            return "Unsupported"
        default:
            return "Unknown"
        }
    }

    var statusIcon: String {
        if isConnected {
            return "link"
        } else if isAdvertising {
            return "dot.radiowaves.left.and.right"
        } else if isBluetoothReady {
            return "dot.radiowaves.left.and.right"
        } else {
            return "exclamationmark.triangle"
        }
    }

    var statusColor: Color {
        if isConnected {
            return .green
        } else if isAdvertising {
            return .blue
        } else if isBluetoothReady {
            return .primary
        } else {
            return .red
        }
    }

    init() {
        bleManager = BLEMIDIPeripheralManager()
        bleManager.delegate = self
    }

    func toggleAdvertising() {
        if isAdvertising {
            bleManager.stopAdvertising()
            isAdvertising = false
            isConnected = false
        } else {
            bleManager.startAdvertising()
        }
    }

    private func sendControlChange() {
        guard isConnected else { return }
        let value = UInt8(min(127, max(0, Int(ccValue))))
        let packet = MIDIPacket.controlChange(channel: 0, controller: 1, value: value)
        bleManager.sendMIDIMessage(packet)
    }
}

// MARK: - BLEMIDIPeripheralManagerDelegate

extension BLEMIDIViewModel: BLEMIDIPeripheralManagerDelegate {

    nonisolated func peripheralManagerDidUpdateState(_ state: CBManagerState) {
        Task { @MainActor in
            self.bluetoothState = state
        }
    }

    nonisolated func peripheralManagerDidStartAdvertising(_ error: Error?) {
        Task { @MainActor in
            self.isAdvertising = error == nil
        }
    }

    nonisolated func peripheralManagerDidConnect() {
        Task { @MainActor in
            self.isConnected = true
        }
    }

    nonisolated func peripheralManagerDidDisconnect() {
        Task { @MainActor in
            self.isConnected = false
        }
    }
}
