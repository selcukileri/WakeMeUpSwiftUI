//
//  EditLocationView.swift
//  WakeMeUpSwiftUI
//
//  Created by Selçuk İleri on 12.11.2025.
//

import SwiftUI
import MapKit
import SwiftData

struct EditLocationView: View {
    @Environment(\.dismiss) private var dismiss
    
    let location: Location
    
    @State private var name: String
    @State private var selectedRadius: Int
    @State private var selectedAlarmType: AlarmType
    @State private var cameraPosition: MapCameraPosition
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let radiusOptions = [500, 1000, 1500, 2000]
    
    init(location: Location) {
        self.location = location
        _name = State(initialValue: location.name)
        _selectedRadius = State(initialValue: location.radius)
        _selectedAlarmType = State(initialValue: location.alarmType)
        _cameraPosition = State(initialValue: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Konum Bilgileri") {
                    TextField("İsim", text: $name)
                }
                
                Section("Konum") {
                    Map(position: $cameraPosition) {
                        Annotation(name.isEmpty ? location.name : name,
                                 coordinate: CLLocationCoordinate2D(
                                    latitude: location.latitude,
                                    longitude: location.longitude
                                 )) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 30))
                                .foregroundStyle(.red)
                        }
                    }
                    .frame(height: 200)
                    .allowsHitTesting(false)
                    
                    Text("Not: Konum değiştirilemez")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Section("Alarm Ayarları") {
                    Picker("Mesafe", selection: $selectedRadius) {
                        ForEach(radiusOptions, id: \.self) { radius in
                            Text("\(radius)m").tag(radius)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Alarm Tipi", selection: $selectedAlarmType) {
                        ForEach(AlarmType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle("Konumu Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        saveChanges()
                    }
                }
            }
            .alert("Uyarı", isPresented: $showAlert) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveChanges() {
        guard !name.isEmpty else {
            alertMessage = "Lütfen konum ismi giriniz"
            showAlert = true
            return
        }
        
        // Location object'i güncelle
        location.name = name
        location.radius = selectedRadius
        location.alarmType = selectedAlarmType
        
        dismiss()
    }
}

#Preview {
    EditLocationView(location: Location(
        name: "Test Lokasyon",
        latitude: 41.0082,
        longitude: 28.9784,
        radius: 500,
        alarmType: .alarm
    ))
    .modelContainer(for: Location.self, inMemory: true)
}
