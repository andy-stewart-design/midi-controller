# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

iOS SwiftUI application that functions as a BLE MIDI peripheral device. Users create customizable sliders that send MIDI Control Change (CC) messages over Bluetooth Low Energy to connected MIDI centrals (DAWs, synths, etc.).

## Build Commands

This is a standard Xcode project with no external dependencies. Build and run using:
- **Build**: `xcodebuild -project midi-controller.xcodeproj -scheme midi-controller build`
- **Run**: Open in Xcode and run on device (BLE requires physical device, not simulator)

No tests, linting, or package management commands exist.

## Architecture

**Pattern**: MVVM with Observable ViewModels

**Key Components**:
- `BLEMIDIPeripheralManager` (Services/) - CoreBluetooth peripheral wrapper, runs on dedicated `bleQueue`
- `BLEMIDIViewModel` (ViewModels/) - Bridge between UI and BLE, marked `@Observable` and `@MainActor`
- `CCSliderConfig` (Models/) - Data model for slider configuration (channel, CC number, value)
- `MIDIPacket` (Utilities/) - Encodes MIDI messages in BLE MIDI packet format

**Data Flow**: Slider change → ViewModel → MIDIPacket encoding → BLEMIDIPeripheralManager → Broadcast to connected centrals

**Threading Model**:
- BLE operations execute on background `DispatchQueue` labeled `com.midi-controller.ble`
- UI state updates marshal to `@MainActor` via Task wrappers
- BLE manager initializes on background queue to prevent main thread blocking

## BLE MIDI Details

The app operates as a BLE **Peripheral** (advertises services that Centrals connect to).

Standard BLE MIDI UUIDs (hardcoded):
- Service: `03B80E5A-EDE8-4B33-A751-6CE34EC4C700`
- Characteristic: `7772E5DB-3868-4112-A1A9-F2669D106BF3`

MIDI values: CC 0-127, Channels 1-16 (0-15 internally)

## Key Files

- `midi_controllerApp.swift` - App entry point, instantiates ViewModel
- `ContentView.swift` - Main slider list UI
- `BLEMIDIPeripheralManager.swift` - Full `CBPeripheralManagerDelegate` implementation
- `BLEMIDIViewModel.swift` - All observable state and MIDI sending logic
