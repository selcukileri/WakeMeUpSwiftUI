//
//  ContentView.swift
//  WakeMeUpSwiftUI
//
//  Created by Selçuk İleri on 5.11.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Konumlar", systemImage: "mappin.circle")
                }
            
            FavoritesView()
                .tabItem {
                    Label("Favoriler", systemImage: "star.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Ayarlar", systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Location.self, inMemory: true)
}
