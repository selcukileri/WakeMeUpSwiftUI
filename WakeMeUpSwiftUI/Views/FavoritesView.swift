//
//  FavoritesView.swift
//  WakeMeUpSwiftUI
//
//  Created by Selçuk İleri on 12.11.2025.
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Location> { $0.isFavorite == true },
           sort: \Location.createdAt,
           order: .reverse)
    private var favoriteLocations: [Location]
    
    @State private var showingAddLocation = false
    
    var body: some View {
        NavigationStack {
            ZStack { 
                Group {
                    if favoriteLocations.isEmpty {
                        emptyStateView
                    } else {
                        locationsList
                    }
                }
                .navigationTitle("Favoriler")
                
                VStack {
                    Spacer()
                    HStack {
                        if !favoriteLocations.isEmpty {
                            Spacer()
                        }
                        
                        Button(action: { showingAddLocation = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                Text("Konum Ekle")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 16)
                            .background(Color.appOrange)
                            .cornerRadius(30)
                            .shadow(color: .black.opacity(0.2), radius: 5)
                        }
                        
                        if !favoriteLocations.isEmpty {
                            Spacer()
                                .frame(width: 20)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, favoriteLocations.isEmpty ? 100 : 90)
                }
            }
            .sheet(isPresented: $showingAddLocation) {
                AddLocationView()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.slash")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            
            Text("Favori Konumunuz Yok")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Sık kullandığınız konumları favorilere ekleyin")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private var locationsList: some View {
        List {
            ForEach(favoriteLocations) { location in
                NavigationLink {
                    TrackingView(location: location)
                } label: {
                    LocationRow(location: location)
                }
            }
            .onDelete(perform: deleteLocations)
        }
    }
    
    private func deleteLocations(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(favoriteLocations[index])
        }
    }
}

#Preview {
    FavoritesView()
        .modelContainer(for: Location.self, inMemory: true)
}
