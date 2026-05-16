//
//  GameSettings.swift
//  CosmicDrift
//
//  Created by Greg Delgado on 16/5/2026.
//

import Foundation
import SwiftData

@Model
class GameSettings {
    var selectedShipColor: String

    init(selectedShipColor: String = "silver") {
        self.selectedShipColor = selectedShipColor
    }
}
