//
//  MIDIPacket.swift
//  midi-controller
//

import Foundation

/// Utility for creating BLE MIDI packets
/// BLE MIDI packet format: [Header] [Timestamp] [Status] [Data1] [Data2]
/// Header: 0x80 | timestamp_high (6 bits)
/// Timestamp: 0x80 | timestamp_low (7 bits)
enum MIDIPacket {

    /// Creates a Control Change MIDI message wrapped in BLE MIDI packet format
    /// - Parameters:
    ///   - channel: MIDI channel (0-15)
    ///   - controller: CC number (0-127)
    ///   - value: CC value (0-127)
    /// - Returns: Data formatted for BLE MIDI transmission
    static func controlChange(channel: UInt8, controller: UInt8, value: UInt8) -> Data {
        let timestamp = currentTimestamp()
        let header = 0x80 | ((timestamp >> 7) & 0x3F)
        let timestampLow = 0x80 | (timestamp & 0x7F)

        // Control Change status byte: 0xB0 | channel
        let status = 0xB0 | (channel & 0x0F)

        return Data([
            UInt8(header),
            UInt8(timestampLow),
            status,
            controller & 0x7F,
            value & 0x7F
        ])
    }

    /// Gets current timestamp in milliseconds, masked to 13 bits for BLE MIDI
    private static func currentTimestamp() -> UInt16 {
        let ms = Int(Date().timeIntervalSince1970 * 1000)
        return UInt16(ms & 0x1FFF)
    }
}
