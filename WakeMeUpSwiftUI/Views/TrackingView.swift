//
//  TrackingView.swift
//  WakeMeUpSwiftUI
//
//  Created by Selçuk İleri on 5.11.2025.
//

import SwiftUI
import MapKit
import AVFoundation

struct TrackingView: View {
    let location: Location
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var alarmTimer: Timer?
    @State private var showingAlarmAlert = false
    
    @State private var locationManager = LocationManager()
    @State private var notificationManager = NotificationManager()

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var remainingDistance: CLLocationDistance = 0
    @State private var isTracking = true
    @State private var hasTriggeredAlarm = false
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        ZStack {
            // Harita
            Map(position: $cameraPosition) {
                // Hedef konum
                Annotation(location.name, coordinate: CLLocationCoordinate2D(
                    latitude: location.latitude,
                    longitude: location.longitude
                )) {
                    ZStack {
                        Circle()
                            .fill(.red.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.red)
                    }
                }
                
                // Kullanıcı konumu
                if let userLocation = locationManager.userLocation {
                    Annotation("Siz", coordinate: userLocation) {
                        Circle()
                            .fill(.blue)
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: 3)
                            )
                    }
                }
            }
            .ignoresSafeArea()
            
            // Üst kısım - Mesafe göstergesi
            VStack {
                distanceCard
                    .padding()
                
                Spacer()
                
                // Alt kısım - Durdur butonu
                Button {
                    stopTracking()
                } label: {
                    Text("Durdur")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.red)
                        .cornerRadius(12)
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    stopTracking()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Geri")
                    }
                }
            }
        }
        .alert("Hedefinize Ulaştınız!", isPresented: $showingAlarmAlert) {
            Button("Tamam") {
                stopAlarm()
                stopTracking()
            }
//            Button("Devam Et", role: .cancel) {
//                stopAlarm()
//            }
        } message: {
            Text("\(location.name) konumuna \(location.radius)m mesafedesiniz.")
        }
        .onAppear {
            notificationManager.requestPermission()
            startTracking()
        }
        .onDisappear {
            stopTracking()
        }
    }
    
    private var distanceCard: some View {
        VStack(spacing: 8) {
            Text("Kalan Mesafe")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(formatDistance(remainingDistance))
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(remainingDistance <= Double(location.radius) ? .red : .primary)
            
            HStack(spacing: 8) {
                Label("\(location.radius)m", systemImage: "scope")
                Text("•")
                Label(location.alarmType.rawValue, systemImage: "bell.fill")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }
    
    private func startTracking() {
        locationManager.startUpdatingLocation()
        isTracking = true
        
        // Haritayı kullanıcı ve hedef arasında konumlandır
        if let userLocation = locationManager.userLocation {
            let targetCoordinate = CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            )
            
            let midLat = (userLocation.latitude + targetCoordinate.latitude) / 2
            let midLon = (userLocation.longitude + targetCoordinate.longitude) / 2
            
            cameraPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: midLat, longitude: midLon),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
        
        // Timer ile mesafe güncelleme
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            guard isTracking else {
                timer.invalidate()
                return
            }
            
            updateDistance()
        }
    }
    
    private func updateDistance() {
        guard let userLocation = locationManager.userLocation else { return }
        
        let targetLocation = CLLocation(
            latitude: location.latitude,
            longitude: location.longitude
        )
        
        let userCLLocation = CLLocation(
            latitude: userLocation.latitude,
            longitude: userLocation.longitude
        )
        
        remainingDistance = userCLLocation.distance(from: targetLocation)
        
        // Alarm kontrolü
        if remainingDistance <= Double(location.radius) && !hasTriggeredAlarm {
            triggerAlarm()
            hasTriggeredAlarm = true
        }
    }
    
    private func triggerAlarm() {
        notificationManager.sendAlarmNotification(
            locationName: location.name,
            radius: location.radius
        )
        
        startContinuousAlarm()
        showingAlarmAlert = true
    }
    
    private func startContinuousAlarm() {
        alarmTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            switch location.alarmType {
            case .alarm:
                playAlarmSound()
            case .vibration:
                vibratePhone()
            case .both:
                playAlarmSound()
                vibratePhone()
            }
        }
    }
    
    private func stopAlarm() {
        alarmTimer?.invalidate()
        alarmTimer = nil
        audioPlayer?.stop()
    }
    
    private func playAlarmSound() {
        AudioServicesPlaySystemSound(1005)
    }
    
    private func vibratePhone() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    private func stopTracking() {
        isTracking = false
        stopAlarm()
        locationManager.stopUpdatingLocation()
        dismiss()
    }
    
    private func formatDistance(_ distance: CLLocationDistance) -> String {
        if distance >= 1000 {
            return String(format: "%.1f km", distance / 1000)
        } else {
            return "\(Int(distance)) m"
        }
    }
}

#Preview {
    NavigationStack {
        TrackingView(location: Location(
            name: "Test Lokasyon",
            latitude: 41.0082,
            longitude: 28.9784,
            radius: 500,
            alarmType: .alarm
        ))
    }
}
