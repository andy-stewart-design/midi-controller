//
//  ContentView.swift
//  midi-controller
//
//  Created by Andy Stewart on 1/26/26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = BLEMIDIViewModel()

    var body: some View {
        VStack(spacing: 32) {
            // Status indicator
            VStack(spacing: 8) {
                Image(systemName: statusIcon)
                    .font(.system(size: 48))
                    .foregroundStyle(statusColor)

                Text(viewModel.statusText)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Advertising toggle
            Toggle("Advertise", isOn: Binding(
                get: { viewModel.isAdvertising },
                set: { _ in viewModel.toggleAdvertising() }
            ))
            .toggleStyle(.switch)
            .disabled(!viewModel.isBluetoothReady)

            // CC Slider
            VStack(spacing: 8) {
                Text("CC Value: \(Int(viewModel.ccValue))")
                    .font(.subheadline)
                    .monospacedDigit()

                Slider(value: $viewModel.ccValue, in: 0...127, step: 1)
                    .disabled(!viewModel.isConnected)
            }

            Spacer()
        }
        .padding(24)
    }

    private var statusIcon: String {
        if viewModel.isConnected {
            return "link.circle.fill"
        } else if viewModel.isAdvertising {
            return "antenna.radiowaves.left.and.right"
        } else if viewModel.isBluetoothReady {
            return "dot.radiowaves.left.and.right"
        } else {
            return "exclamationmark.triangle"
        }
    }

    private var statusColor: Color {
        if viewModel.isConnected {
            return .green
        } else if viewModel.isAdvertising {
            return .blue
        } else if viewModel.isBluetoothReady {
            return .primary
        } else {
            return .red
        }
    }
}

#Preview {
    ContentView()
}
