//
//  HomeView.swift
//  WakeMeUpSwiftUI
//
//  Created by Selçuk İleri on 5.11.2025.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var locations: [Location]
    @State private var showingAddLocation = false
    
    var body: some View {
        NavigationStack {
            Group {
                if locations.isEmpty {
                    emptyStateView
                } else {
                    locationsList
                }
            }
            .navigationTitle("Wake Me Up")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddLocation = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddLocation) {
                AddLocationView()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            
            Text("Henüz Konum Eklemediniz")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Alarm çalmasını istediğiniz konumları ekleyin")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showingAddLocation = true
            } label: {
                Label("Konum Ekle", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
        }
    }
    
    private var locationsList: some View {
        List {
            ForEach(locations) { location in
                NavigationLink {
//                    TrackingView(location: location)
                } label: {
                    LocationRow(location: location)
                }
            }
            .onDelete(perform: deleteLocations)
        }
    }
    
    private func deleteLocations(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(locations[index])
        }
    }
}

struct LocationRow: View {
    let location: Location
    
    var body: some View {
        HStack {
            Image(systemName: "mappin.circle.fill")
                .font(.title2)
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.headline)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(location.radius)m")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .cornerRadius(6)
                
                Text(location.alarmType.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Location.self, inMemory: true)
}
