//
//  Location.swift
//  WakeMeUpSwiftUI
//
//  Created by Selçuk İleri on 5.11.2025.
//

import Foundation
import SwiftData

@Model
class Location {
    var id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var radius: Int
    var alarmType: AlarmType
    var createdAt: Date
    var isFavorite: Bool
    
    init(name: String, latitude: Double, longitude: Double,
         radius: Int = 500, alarmType: AlarmType = .alarm, isFavorite: Bool = false) {
        self.id = UUID()
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        self.alarmType = alarmType
        self.createdAt = Date()
        self.isFavorite = isFavorite
    }
}
