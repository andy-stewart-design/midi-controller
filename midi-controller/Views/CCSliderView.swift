//
//  CCSliderView.swift
//  midi-controller
//

import SwiftUI

struct CCSliderView: View {
    @Binding var slider: CCSliderConfig
    var isConnected: Bool
    var onValueChanged: (CCSliderConfig) -> Void
    var onDelete: () -> Void

    @State private var showSettings = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(slider.labelName): \(Int(slider.value))")
                    .font(.subheadline)
                    .monospacedDigit()

                Spacer()

                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(.foreground)
                        .opacity(0.6)
                }
            }

            Slider(value: $slider.value, in: 0...127, step: 1)
                .disabled(!isConnected)
                .onChange(of: slider.value) { _, _ in
                    onValueChanged(slider)
                }
        }
        .sheet(isPresented: $showSettings) {
            CCSliderSettingsSheet(slider: $slider, onDelete: onDelete)
        }
    }
}
