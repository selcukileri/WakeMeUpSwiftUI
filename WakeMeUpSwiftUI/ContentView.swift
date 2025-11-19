//
//  ContentView.swift
//  WakeMeUpSwiftUI
//
//  Created by Selçuk İleri on 5.11.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var showingAddLocation = false
    @State private var selectedTab = 0
    @State private var notificationManager = NotificationManager()
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Konumlar", systemImage: "mappin.circle")
                    }
                    .tag(0)
                
                FavoritesView()
                    .tabItem {
                        Label("Favoriler", systemImage: "star.fill")
                    }
                    .tag(1)
                
                SettingsView()
                    .tabItem {
                        Label("Ayarlar", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }
            .tint(.appOrange)
            .onAppear {
                notificationManager.requestPermission()
            }
        }
    }
}
