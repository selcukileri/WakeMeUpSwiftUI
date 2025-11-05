//
//  AlarmType.swift
//  WakeMeUpSwiftUI
//
//  Created by Selçuk İleri on 5.11.2025.
//

import Foundation

enum AlarmType: String, Codable, CaseIterable {
    case alarm = "Alarm"
    case vibration = "Titreşim"
    case both = "Alarm ve Titreşim"
}
