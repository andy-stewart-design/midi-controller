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
    private(set) var connectionCount = 0
    private(set) var bluetoothState: CBManagerState = .unknown

    var isConnected: Bool {
        connectionCount > 0
    }

    var sliders: [CCSliderConfig] = [CCSliderConfig()]

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

    var connectionCountText: String {
        "\(connectionCount) \(connectionCount == 1 ? "Device" : "Devices")"
    }

    init() {
        bleManager = BLEMIDIPeripheralManager()
        bleManager.delegate = self
    }

    func toggleAdvertising() {
        if isAdvertising {
            bleManager.stopAdvertising()
            isAdvertising = false
            connectionCount = 0
        } else {
            bleManager.startAdvertising()
        }
    }

    func sendControlChange(for slider: CCSliderConfig) {
        guard isConnected else { return }
        let value = UInt8(min(127, max(0, Int(slider.value))))
        let channel = UInt8(min(15, max(0, slider.channel - 1)))
        let controller = UInt8(min(127, max(0, slider.ccNumber)))
        let packet = MIDIPacket.controlChange(channel: channel, controller: controller, value: value)
        bleManager.sendMIDIMessage(packet)
    }

    func addSlider() {
        let nextChannel = min(16, sliders.count + 1)
        let newSlider = CCSliderConfig(
            labelName: "CC Value",
            channel: nextChannel,
            ccNumber: 1
        )
        sliders.append(newSlider)
    }

    func removeSlider(id: UUID) {
        sliders.removeAll { $0.id == id }
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

    nonisolated func peripheralManagerDidConnect(_ device: ConnectedDevice) {
        Task { @MainActor in
            self.connectionCount += 1
        }
    }

    nonisolated func peripheralManagerDidDisconnect(_ device: ConnectedDevice) {
        Task { @MainActor in
            self.connectionCount = max(0, self.connectionCount - 1)
        }
    }
}
