//
//  LocationManager.swift
//  WakeMeUpSwiftUI
//
//  Created by Selçuk İleri on 5.11.2025.
//

import Foundation
import CoreLocation
import Combine

@Observable
class LocationManager: NSObject {
    var userLocation: CLLocationCoordinate2D?
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var isUpdatingLocation = false
    var locationServicesEnabled = true
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        authorizationStatus = locationManager.authorizationStatus
        checkLocationServicesEnabled()
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func checkLocationServicesEnabled() {
        Task {
            let enabled = CLLocationManager.locationServicesEnabled()
            await MainActor.run {
                self.locationServicesEnabled = enabled
            }
        }
    }
    
    func startUpdatingLocation() {
        Task {
            let enabled = CLLocationManager.locationServicesEnabled()
            await MainActor.run {
                guard enabled else {
                    self.locationServicesEnabled = false
                    return
                }
                self.locationManager.startUpdatingLocation()
                self.isUpdatingLocation = true
            }
        }
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        DispatchQueue.main.async {
            self.isUpdatingLocation = false
        }
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    func distance(from coordinate: CLLocationCoordinate2D) -> CLLocationDistance? {
        guard let userLocation = userLocation else { return nil }
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let targetLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return userCLLocation.distance(from: targetLocation)
    }
    
    var hasLocationPermission: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task {
            let enabled = CLLocationManager.locationServicesEnabled()
            await MainActor.run {
                self.authorizationStatus = status
                self.locationServicesEnabled = enabled
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
