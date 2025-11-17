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
    
    var body: some View {
        ZStack {
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
            
            .tint(.appOrange)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showingAddLocation = true }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.appOrange)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 5)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 70) 
                }
            }
        }
        .sheet(isPresented: $showingAddLocation) {
            AddLocationView()
        }
    }
}
