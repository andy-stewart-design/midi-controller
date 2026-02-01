//
//  CCSliderConfig.swift
//  midi-controller
//

import Foundation

struct CCSliderConfig: Identifiable {
    let id: UUID
    var labelName: String
    var channel: Int      // 1-16 (user-facing)
    var ccNumber: Int     // 1-127 (CC controller number)
    var value: Double     // 0-127

    init(
        id: UUID = UUID(),
        labelName: String = "CC Value",
        channel: Int = 1,
        ccNumber: Int = 1,
        value: Double = 0
    ) {
        self.id = id
        self.labelName = labelName
        self.channel = channel
        self.ccNumber = ccNumber
        self.value = value
    }

    init(from entity: CCSliderConfigEntity) {
        self.id = entity.id
        self.labelName = entity.labelName
        self.channel = entity.channel
        self.ccNumber = entity.ccNumber
        self.value = entity.value
    }

    func update(_ entity: CCSliderConfigEntity) {
        entity.labelName = labelName
        entity.channel = channel
        entity.ccNumber = ccNumber
        entity.value = value
    }
}
