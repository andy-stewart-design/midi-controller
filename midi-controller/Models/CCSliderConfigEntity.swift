//
//  CCSliderConfigEntity.swift
//  midi-controller
//

import Foundation
import SwiftData

@Model
final class CCSliderConfigEntity {
    @Attribute(.unique) var id: UUID
    var labelName: String
    var channel: Int
    var ccNumber: Int
    var value: Double
    var sortOrder: Int

    init(
        id: UUID = UUID(),
        labelName: String = "CC Value",
        channel: Int = 1,
        ccNumber: Int = 1,
        value: Double = 0,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.labelName = labelName
        self.channel = channel
        self.ccNumber = ccNumber
        self.value = value
        self.sortOrder = sortOrder
    }
}
