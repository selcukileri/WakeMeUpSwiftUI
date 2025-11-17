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
            ZStack {
                Group {
                    if locations.isEmpty {
                        emptyStateView
                    } else {
                        locationsList
                    }
                }
                .navigationTitle("Wake Me Up")
                
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
                        .padding(.bottom, 90)
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
        }
    }
    
    private var locationsList: some View {
        List {
            ForEach(locations) { location in
                NavigationLink {
                    LocationDetailView(location: location)
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
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        HStack {
            Image(systemName: "location.circle.fill")
                .font(.title2)
                .foregroundStyle(.appOrange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.headline)
            }
            
            Spacer()
            
            Button {
                location.isFavorite.toggle()
            } label: {
                Image(systemName: location.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(location.isFavorite ? .yellow : .gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(location.radius)m")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.appOrange.opacity(0.1))
                    .foregroundStyle(.appOrange)
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
