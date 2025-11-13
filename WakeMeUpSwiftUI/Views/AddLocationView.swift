//
//  AddLocationView.swift
//  WakeMeUpSwiftUI
//
//  Created by Selçuk İleri on 5.11.2025.
//

import SwiftUI
import MapKit
import SwiftData

struct AddLocationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var locationManager = LocationManager()
    @State private var searchService = LocationSearchService()
    
    @State private var showHint = true
    @State private var showingSearch = false
    @State private var name = ""
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var selectedRadius = 500
    @State private var selectedAlarmType: AlarmType = .alarm
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSettings = false
    
    let radiusOptions = [500, 1000, 1500, 2000]
    
    var body: some View {
        NavigationStack {
            ZStack {
                MapReader { proxy in
                    Map(position: $cameraPosition) {
                        if let coordinate = selectedCoordinate {
                            Annotation(name.isEmpty ? "Seçilen Konum" : name,
                                       coordinate: coordinate) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.red)
                            }
                        }

                        if let userLocation = locationManager.userLocation {
                            Annotation("Konumunuz", coordinate: userLocation) {
                                Image(systemName: "location.fill")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    .gesture(
                        LongPressGesture(minimumDuration: 0.3)
                            .sequenced(before: DragGesture(minimumDistance: 0))
                            .onEnded { value in
                                switch value {
                                case .second(true, let drag):
                                    if let location = drag?.location,
                                       let coordinate = proxy.convert(location, from: .local) {
                                        selectedCoordinate = coordinate
                                        withAnimation {
                                            showHint = false
                                        }
                                    }
                                default:
                                    break
                                }
                            }
                    )
                }
                .ignoresSafeArea()
                
                VStack {
                    HStack(spacing: 12) {
                        Button {
                            showingSearch = true
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundStyle(.secondary)
                                Text("Konum ara...")
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            if let userLocation = locationManager.userLocation {
                                cameraPosition = .region(MKCoordinateRegion(
                                    center: userLocation,
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                ))
                            }
                        } label: {
                            Image(systemName: "location.fill")
                                .font(.title3)
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    if selectedCoordinate == nil && showHint {
                        HStack(spacing: 8) {
                            Image(systemName: "hand.tap.fill")
                                .foregroundStyle(.blue)
                            Text("Haritayı basılı tutarak konum seçin")
                                .font(.caption)
                                .foregroundStyle(.primary)
                        }
                        .padding()
                        .background(.blue.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.top, 4)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        TextField("Konum İsmi", text: $name)
                            .font(.body)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Mesafe", systemImage: "scope")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Picker("Mesafe", selection: $selectedRadius) {
                                ForEach(radiusOptions, id: \.self) { radius in
                                    Text("\(radius)m").tag(radius)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Alarm Tipi", systemImage: "bell.fill")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            HStack(spacing: 12) {
                                ForEach(AlarmType.allCases, id: \.self) { type in
                                    Button {
                                        selectedAlarmType = type
                                    } label: {
                                        VStack(spacing: 8) {
                                            Image(systemName: type == .alarm ? "speaker.wave.2" :
                                                               type == .vibration ? "iphone.radiowaves.left.and.right" :
                                                               "bell.and.waves.left.and.right")
                                                .font(.title2)
                                            
                                            Text(type.rawValue)
                                                .font(.caption)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(selectedAlarmType == type ? Color.blue : Color.clear)
                                        .foregroundStyle(selectedAlarmType == type ? .white : .primary)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedAlarmType == type ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                    .background(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()
                    )
                }
            }
            .navigationTitle("Yeni Konum")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        saveLocation()
                    }
                }
            }
            .sheet(isPresented: $showingSearch) {
                searchView
            }
            .alert("Uyarı", isPresented: $showAlert) {
                Button("Tamam", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                if !locationManager.hasLocationPermission {
                    showAlert = true
                    alertMessage = "Konum izni olmadan harita kullanılamaz. Lütfen ayarlardan izin verin."
                    return
                }
                
                locationManager.startUpdatingLocation()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if let userLocation = locationManager.userLocation {
                        cameraPosition = .region(MKCoordinateRegion(
                            center: userLocation,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        ))
                    }
                }
            }
            .onDisappear {
                locationManager.stopUpdatingLocation()
            }
        }
    }
    
    private var searchView: some View {
        NavigationStack {
            List {
                ForEach(searchService.searchResults, id: \.self) { result in
                    Button {
                        selectSearchResult(result)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.title)
                                .font(.headline)
                            Text(result.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .searchable(text: $searchService.searchQuery, prompt: "Konum ara")
            .onChange(of: searchService.searchQuery) { oldValue, newValue in
                searchService.updateSearch(newValue)
            }
            .navigationTitle("Konum Ara")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        showingSearch = false
                    }
                }
            }
        }
    }
    
    private func selectSearchResult(_ result: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: result)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let mapItem = response?.mapItems.first else { return }
            let coordinate = mapItem.placemark.coordinate
            
            selectedCoordinate = coordinate
            name = result.title
            showHint = false
            
            cameraPosition = .region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
            
            showingSearch = false
        }
    }
    
    private func saveLocation() {
        guard !name.isEmpty else {
            alertMessage = "Lütfen konum ismi giriniz"
            showAlert = true
            return
        }
        
        guard let coordinate = selectedCoordinate else {
            alertMessage = "Lütfen haritadan konum seçiniz"
            showAlert = true
            return
        }
        
        let newLocation = Location(
            name: name,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            radius: selectedRadius,
            alarmType: selectedAlarmType
        )
        
        modelContext.insert(newLocation)
        dismiss()
    }
}

#Preview {
    AddLocationView()
        .modelContainer(for: Location.self, inMemory: true)
}
