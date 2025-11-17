//
//  LocationDetailView.swift
//  WakeMeUpSwiftUI
//
//  Created by Selçuk İleri on 12.11.2025.
//

import SwiftUI
import MapKit
import SwiftData

struct LocationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let location: Location
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: location.latitude,
                        longitude: location.longitude
                    ),
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))) {
                    Annotation(location.name, coordinate: CLLocationCoordinate2D(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(.red)
                    }
                }
                .frame(height: 250)
                .cornerRadius(12)
                .allowsHitTesting(false)
                
                VStack(spacing: 16) {
                    infoRow(icon: "mappin.circle.fill", title: "Konum", value: location.name)
                    infoRow(icon: "scope", title: "Mesafe", value: "\(location.radius)m")
                    infoRow(icon: "bell.fill", title: "Alarm Tipi", value: location.alarmType.rawValue)
                    infoRow(icon: "star.fill", title: "Favori", value: location.isFavorite ? "Evet" : "Hayır")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                VStack(spacing: 12) {
                    NavigationLink {
                        TrackingView(location: location)
                    } label: {
                        Text("Alarm Başlat")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appTeal)
                            .cornerRadius(12)
                    }
                    
                    Button {
                        showingEditSheet = true
                    } label: {
                        Text("Düzenle")
                            .font(.headline)
                            .foregroundStyle(.appTeal)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appTeal.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Text("Sil")
                            .font(.headline)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Konum Detayı")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            EditLocationView(location: location)
        }
        .alert("Konumu Sil?", isPresented: $showingDeleteAlert) {
            Button("İptal", role: .cancel) { }
            Button("Sil", role: .destructive) {
                modelContext.delete(location)
                dismiss()
            }
        } message: {
            Text("\(location.name) konumu silinecek. Emin misiniz?")
        }
    }
    
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            Text(title)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    NavigationStack {
        LocationDetailView(location: Location(
            name: "Test Lokasyon",
            latitude: 41.0082,
            longitude: 28.9784,
            radius: 500,
            alarmType: .alarm
        ))
    }
    .modelContainer(for: Location.self, inMemory: true)
}
