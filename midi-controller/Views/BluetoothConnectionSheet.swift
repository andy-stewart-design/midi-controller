//
//  BluetoothConnectionSheet.swift
//  midi-controller
//

import SwiftUI

struct BluetoothConnectionSheet: View {
    @Bindable var viewModel: BLEMIDIViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Status indicator
                VStack(spacing: 8) {
                    Image(systemName: viewModel.statusIcon)
                        .font(.system(size: 48))
                        .foregroundStyle(viewModel.statusColor)

                    Text(viewModel.statusText)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 24)

                Divider()

                // Advertising toggle
                Toggle("Advertise", isOn: Binding(
                    get: { viewModel.isAdvertising },
                    set: { _ in viewModel.toggleAdvertising() }
                ))
                .toggleStyle(.switch)
                .disabled(!viewModel.isBluetoothReady)
                .padding(.horizontal)

                Spacer()
            }
            .padding(24)
            .navigationTitle("Bluetooth")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    BluetoothConnectionSheet(viewModel: BLEMIDIViewModel())
}
