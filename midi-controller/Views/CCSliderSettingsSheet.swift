//
//  CCSliderSettingsSheet.swift
//  midi-controller
//

import SwiftUI

struct CCSliderSettingsSheet: View {
    @Bindable var viewModel: BLEMIDIViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Label") {
                    TextField("Name", text: $viewModel.ccLabelName)
                }

                Section("MIDI") {
                    Picker("Channel", selection: $viewModel.ccChannel) {
                        ForEach(1...16, id: \.self) { channel in
                            Text("\(channel)").tag(channel)
                        }
                    }
                }
            }
            .navigationTitle("Slider Settings")
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
    CCSliderSettingsSheet(viewModel: BLEMIDIViewModel())
}
