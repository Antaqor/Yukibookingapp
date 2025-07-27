// StyleKit.swift
import SwiftUI
import UIKit

// Brand colors
extension Color {
    /// Primary brand color #E4897C
    static let brand = Color(red: 228/255, green: 137/255, blue: 124/255)
    static let fieldBG = Color(.systemGray6)
}

// Primary filled button
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.brand.opacity(configuration.isPressed ? 0.9 : 1))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.18), value: configuration.isPressed)
    }
}

// Secondary outline button
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: 50)
            .foregroundColor(.brand)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.brand, lineWidth: 1.5)
            )
            .background(Color.white.opacity(configuration.isPressed ? 0.02 : 0))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.18), value: configuration.isPressed)
    }
}

// Card container with subtle shadow
struct SurfaceCard<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title).font(.system(size: 22, weight: .bold))
            content
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 18, x: 0, y: 12)
        .padding(.horizontal, 16)
    }
}

// Haptics helper
enum Haptics {
    static func tap() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
}
