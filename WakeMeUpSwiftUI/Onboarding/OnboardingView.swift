//
//  OnboardingView.swift
//  WakeMeUpSwiftUI
//
//  Created by Selçuk İleri on 13.11.2025.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                
                OnboardingPageView(
                    icon: "bell.badge.fill",
                    iconColor: .blue,
                    title: "Wake Me Up'a Hoş Geldiniz",
                    description: "Toplu taşımada uyurken durağınızı kaçırmayın. Hedefinize yaklaştığınızda sizi uyandırır!",
                    showButton: false
                )
                .tag(0)
                
                OnboardingPageView(
                    icon: "map.fill",
                    iconColor: .red,
                    title: "Hedef Belirleyin",
                    description: "Haritadan durağınızı seçin, mesafe ve alarm tipini ayarlayın. Hepsi bu kadar!",
                    showButton: false
                )
                .tag(1)
                
                OnboardingPageView(
                    icon: "checkmark.circle.fill",
                    iconColor: .green,
                    title: "Rahat Uyuyun",
                    description: "Hedefinize yaklaştığınızda otomatik alarm çalar. Artık uyumanın tadını çıkarabilirsiniz!",
                    showButton: true,
                    buttonAction: {
                        completeOnboarding()
                    }
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            if currentPage < 2 {
                VStack {
                    HStack {
                        Spacer()
                        Button("Geç") {
                            completeOnboarding()
                        }
                        .foregroundStyle(.secondary)
                        .padding()
                    }
                    Spacer()
                }
            }
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        dismiss()
    }
}

struct OnboardingPageView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let showButton: Bool
    var buttonAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 100))
                .foregroundStyle(iconColor)
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            
            if showButton {
                Button {
                    buttonAction?()
                } label: {
                    Text("Başlayalım")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
