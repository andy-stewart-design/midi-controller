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

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
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
        }
    }
}

#Preview {
    ContentView()
}
