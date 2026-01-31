//
//  ContentView.swift
//  midi-controller
//
//  Created by Andy Stewart on 1/26/26.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = BLEMIDIViewModel()
    @State private var showBluetoothSheet = false
    @State private var showSliderSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // CC Slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(viewModel.ccLabelName): \(Int(viewModel.ccValue))")
                            .font(.subheadline)
                            .monospacedDigit()

                        Spacer()

                        Button {
                            showSliderSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .foregroundStyle(.foreground)
                                .opacity(0.6)
                        }
                    }

                    Slider(value: $viewModel.ccValue, in: 0...127, step: 1)
                        .disabled(!viewModel.isConnected)
                }

                Spacer()
            }
            .padding(24)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showBluetoothSheet = true
                    } label: {
                        Image(systemName: viewModel.statusIcon)
                            .foregroundStyle(viewModel.statusColor)
                    }
                }
            }
            .sheet(isPresented: $showBluetoothSheet) {
                BluetoothConnectionSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showSliderSettings) {
                CCSliderSettingsSheet(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
