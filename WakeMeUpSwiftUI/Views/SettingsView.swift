//
//  SettingsView.swift
//  WakeMeUpSwiftUI
//
//  Created by Selçuk İleri on 13.11.2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var notificationManager = NotificationManager()
    @State private var locationManager = LocationManager()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "bell.badge.fill")
                            .foregroundStyle(.blue)
                        Text("Wake Me Up")
                            .font(.headline)
                        Spacer()
                        Text("v1.0")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Uygulama")
                }
                
                Section {
                    PermissionRow(
                        icon: "location.fill",
                        title: "Konum İzni",
                        isGranted: locationManager.hasLocationPermission,
                        color: .blue
                    )
                    
                    PermissionRow(
                        icon: "bell.fill",
                        title: "Bildirim İzni",
                        isGranted: notificationManager.isAuthorized,
                        color: .red
                    )
                    
                    .onAppear {
                        notificationManager.checkPermissionStatus()
                    }
                    .onChange(of: scenePhase) { oldPhase, newPhase in
                        if newPhase == .active {
                            notificationManager.checkPermissionStatus()
                        }
                    }
                    
                } header: {
                    Text("İzinler")
                } footer: {
                    Text("Alarm çalabilmesi için tüm izinler gereklidir.")
                }
                
                Section {
                    NavigationLink {
                        privacyPolicyView
                    } label: {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundStyle(.gray)
                            Text("Gizlilik Politikası")
                        }
                    }
                    
                    NavigationLink {
                        termsView
                    } label: {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundStyle(.gray)
                            Text("Kullanım Koşulları")
                        }
                    }
                } header: {
                    Text("Yasal")
                }
                
                Section {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(.gray)
                        Text("Destek")
                        Spacer()
                        Text("support@wakemeup.app")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    .onTapGesture {
                        if let url = URL(string: "mailto:support@wakemeup.app") {
                            UIApplication.shared.open(url)
                        }
                    }
                } header: {
                    Text("İletişim")
                }
            }
            .navigationTitle("Ayarlar")
            .onAppear {
                notificationManager.checkPermissionStatus()
            }
        }
    }
    
    private var privacyPolicyView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Gizlilik Politikası")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Son Güncelleme: 13 Kasım 2025")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("""
                Wake Me Up uygulaması, konumunuzu yalnızca alarm çalması için kullanır.

                **Toplanan Veriler:**
                - Konum bilgisi (sadece cihazda saklanır)
                - Kaydedilen alarm konumları

                **Veri Paylaşımı:**
                Hiçbir veriniz 3. taraflarla paylaşılmaz veya sunucularımıza gönderilmez.

                **Veri Saklama:**
                Tüm veriler yalnızca cihazınızda saklanır ve uygulamayı sildiğinizde tamamen silinir.

                **Konum Kullanımı:**
                Konum izni yalnızca alarm başlattığınızda aktif olur ve hedefinize ulaştığınızda otomatik olarak durdurulur. Alarm aktif değilken konum takibi yapılmaz.

                **Arka Plan Kullanımı:**
                Alarm aktifken arka planda konumunuzu takip ederiz, böylece uyurken bile sizi uyandırabiliriz. Alarm durdurulduğunda arka plan takibi de durur.

                **İletişim:**
                Gizlilik politikası ile ilgili sorularınız için: support@wakemeup.app
                """)
                .font(.body)
            }
            .padding()
        }
        .navigationTitle("Gizlilik Politikası")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var termsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Kullanım Koşulları")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Son Güncelleme: 13 Kasım 2025")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("""
                Wake Me Up uygulamasını kullanarak aşağıdaki koşulları kabul etmiş olursunuz.
                
                **Kullanım:**
                - Uygulama "olduğu gibi" sunulmaktadır
                - Toplu taşımada kullanım için tasarlanmıştır
                - Harita ve arama için internet bağlantısı gereklidir
                
                **Sorumluluk:**
                Uygulama yalnızca yardımcı bir araçtır. Önemli yolculuklarda ek önlemler alınmalıdır. Alarm çalmazsa veya geç çalarsa sorumluluk kabul edilmez.
                
                **Kullanım Önerileri:**
                • Telefonunuzun sesini açık tutun
                • Batarya seviyenizi kontrol edin
                • Kritik yolculuklarda ek alarm kurun
                
                **İletişim:**
                Sorularınız için: support@wakemeup.app
                """)
                .font(.body)
            }
            .padding()
        }
        .navigationTitle("Kullanım Koşulları")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let isGranted: Bool
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(title)
            Spacer()
            Image(systemName: isGranted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(isGranted ? .green : .red)
        }
        .onTapGesture {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
    }
}

#Preview {
    SettingsView()
}
