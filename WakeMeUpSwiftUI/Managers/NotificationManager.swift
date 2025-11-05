//
//  NotificationManager.swift
//  WakeMeUpSwiftUI
//
//  Created by Selçuk İleri on 5.11.2025.
//

import Foundation
import UserNotifications

@Observable
class NotificationManager {
    var isAuthorized = false
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
            
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func sendAlarmNotification(locationName: String, radius: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Hedefinize Ulaştınız! 🎯"
        content.body = "\(locationName) konumuna \(radius)m mesafedesiniz."
        content.sound = .defaultCritical // Kritik ses - sessiz modda bile çalar
        content.categoryIdentifier = "ALARM"
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Hemen gönder
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error.localizedDescription)")
            }
        }
    }
    
    func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
}
