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
            List {
                ForEach($viewModel.sliders) { $slider in
                    CCSliderView(
                        slider: $slider,
                        onValueChanged: { updatedSlider in
                            viewModel.sendControlChange(for: updatedSlider)
                        },
                        onDelete: {
                            viewModel.removeSlider(id: slider.id)
                        }
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24))
                }

                Button {
                    viewModel.addSlider()
                } label: {
                    Label("Add Slider", systemImage: "plus")
                        .font(.subheadline)
                }
                .listRowSeparator(.hidden)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            }
            .listStyle(.plain)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showBluetoothSheet = true
                    } label: {
                        Image(systemName: viewModel.statusIcon)
                            .font(.system(size: 14))
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
