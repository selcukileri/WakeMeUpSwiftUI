//
//  WakeMeUpSwiftUIApp.swift
//  WakeMeUpSwiftUI
//
//  Created by Selçuk İleri on 5.11.2025.
//

import SwiftUI
import SwiftData

@main
struct WakeMeUpSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: Location.self)
    }
}
