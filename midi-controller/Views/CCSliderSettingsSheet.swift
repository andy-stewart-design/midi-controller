//
//  CCSliderSettingsSheet.swift
//  midi-controller
//

import SwiftUI

struct CCSliderSettingsSheet: View {
    @Binding var slider: CCSliderConfig
    var onDelete: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Label") {
                    TextField("Name", text: $slider.labelName)
                }

                Section("MIDI") {
                    Picker("Channel", selection: $slider.channel) {
                        ForEach(1...16, id: \.self) { channel in
                            Text("\(channel)").tag(channel)
                        }
                    }

                    Picker("CC Number", selection: $slider.ccNumber) {
                        ForEach(1...127, id: \.self) { cc in
                            Text("\(cc)").tag(cc)
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        dismiss()
                        onDelete()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete Slider")
                            Spacer()
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
