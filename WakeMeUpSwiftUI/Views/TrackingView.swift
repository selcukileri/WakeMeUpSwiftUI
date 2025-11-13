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
    
    @State private var snoozeCountdown: Int? = nil
    @State private var snoozeTimer: Timer?
    
    @State private var initialSpan: MKCoordinateSpan?
    
    @State private var locationManager = LocationManager()
    @State private var notificationManager = NotificationManager()

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var remainingDistance: CLLocationDistance = 0
    @State private var isTracking = true
    @State private var hasTriggeredAlarm = false
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        ZStack {
            if !locationManager.hasLocationPermission || !locationManager.locationServicesEnabled {
                permissionErrorView
            } else {
                mapView
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
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
            Button("1 Dakika Sonra Tekrar Çal", role: .cancel) {
                stopAlarm()
                startSnooze()
            }
        } message: {
            Text("\(location.name) konumuna \(location.radius)m mesafedesiniz.")
        }
        .onAppear {
            if locationManager.hasLocationPermission && locationManager.locationServicesEnabled {
                setupAudioSession()
                notificationManager.requestPermission()
                startTracking()
            }
        }
        .onDisappear {
            stopTracking()
        }
    }
    
    private var permissionErrorView: some View {
        VStack(spacing: 20) {
            Image(systemName: locationManager.locationServicesEnabled ? "location.slash" : "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
            
            Text(locationManager.locationServicesEnabled ? "Konum İzni Gerekli" : "GPS Kapalı")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(locationManager.locationServicesEnabled ?
                 "Alarm çalabilmesi için konum izni vermelisiniz" :
                 "Konum servislerini açmanız gerekiyor")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Ayarları Aç")
                    .font(.headline)
                    .padding()
                    .background(Color.orange)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }
        }
    }
    
    private var mapView: some View {
        ZStack {
            Map(position: $cameraPosition) {
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
            
            VStack {
                if let countdown = snoozeCountdown {
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .foregroundStyle(.orange)
                        Text("Tekrar alarm: \(countdown)s")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .background(.orange.opacity(0.2))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                distanceCard
                    .padding()
                
                Spacer()
                
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
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.duckOthers, .interruptSpokenAudioAndMixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }
    
    private func startSnooze() {
        withAnimation {
            snoozeCountdown = 60
        }
        
        snoozeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if let countdown = snoozeCountdown {
                if countdown > 0 {
                    snoozeCountdown = countdown - 1
                } else {
                    timer.invalidate()
                    snoozeTimer = nil
                    withAnimation {
                        snoozeCountdown = nil
                    }
                    triggerAlarm()
                }
            }
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
        
        if let userLocation = locationManager.userLocation {
            let targetCoordinate = CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            )
            
            let midLat = (userLocation.latitude + targetCoordinate.latitude) / 2
            let midLon = (userLocation.longitude + targetCoordinate.longitude) / 2
            
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            initialSpan = span // İlk zoom'u kaydet
            
            cameraPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: midLat, longitude: midLon),
                span: span
            ))
        }
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            guard isTracking else {
                timer.invalidate()
                return
            }
            
            updateDistance()
            updateCameraPosition()
        }
    }

    private func updateCameraPosition() {
        guard let userLocation = locationManager.userLocation,
              let span = initialSpan else { return }
        
        let targetCoordinate = CLLocationCoordinate2D(
            latitude: location.latitude,
            longitude: location.longitude
        )
        
        let midLat = (userLocation.latitude + targetCoordinate.latitude) / 2
        let midLon = (userLocation.longitude + targetCoordinate.longitude) / 2
        
        cameraPosition = .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: midLat, longitude: midLon),
            span: span 
        ))
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
        
        print("📍 Mesafe güncellendi: \(Int(remainingDistance))m - \(Date().formatted(date: .omitted, time: .standard))")

        
        if remainingDistance <= Double(location.radius) && !hasTriggeredAlarm {
            triggerAlarm()
            hasTriggeredAlarm = true
        }
    }
    
    private func vibratePhone() {
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.5) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        }
    }
    
    private func playAlarmSound() {
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio activation error: \(error)")
        }
        
        guard let url = Bundle.main.url(forResource: "iphone_alarm", withExtension: "mp3") else {
            print("Alarm sesi bulunamadı")
            AudioServicesPlaySystemSound(1005)
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = 1.0
            audioPlayer?.play()
        } catch {
            print("Ses çalma hatası: \(error)")
            AudioServicesPlaySystemSound(1005)
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
        audioPlayer = nil
    }
    
    private func stopTracking() {
        isTracking = false
        stopAlarm()
        snoozeTimer?.invalidate()
        snoozeTimer = nil
        snoozeCountdown = nil
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
