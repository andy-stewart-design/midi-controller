//
//  CCSliderView.swift
//  midi-controller
//

import SwiftUI

struct CCSliderView: View {
    @Binding var slider: CCSliderConfig
    var onValueChanged: (CCSliderConfig) -> Void
    var onSettingsChanged: (CCSliderConfig) -> Void
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
                .buttonStyle(.borderless)
            }

            Slider(value: $slider.value, in: 0...127, step: 1)
                .onChange(of: slider.value) { _, _ in
                    onValueChanged(slider)
                }
        }
        .sheet(isPresented: $showSettings) {
            CCSliderSettingsSheet(slider: $slider, onDelete: onDelete)
        }
        .onChange(of: showSettings) { wasShowing, isShowing in
            if wasShowing && !isShowing {
                onSettingsChanged(slider)
            }
        }
    }
}
