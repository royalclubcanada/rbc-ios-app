import SwiftUI

// MARK: - Design System / Colors

extension Color {
    // Primary Brand Gradients
    static let royalGradientStart = Color(red: 0.2, green: 0.3, blue: 0.9) // Deep Royal Blue
    static let royalGradientEnd = Color(red: 0.5, green: 0.1, blue: 0.8)   // Vibrant Purple
    
    // Glass Accents
    static let glassWhite = Color.white.opacity(0.25)
    static let glassBorder = Color.white.opacity(0.4)
    static let glassShadow = Color.black.opacity(0.15)
    static let backgroundLight = Color(red: 0.95, green: 0.96, blue: 0.99)
    static let backgroundDark = Color(red: 0.05, green: 0.05, blue: 0.1)
    
    // Status
    static let liquidSuccess = Color(red: 0.2, green: 0.8, blue: 0.5)
}

extension LinearGradient {
    static let royalLiquid = LinearGradient(
        gradient: Gradient(colors: [.royalGradientStart, .royalGradientEnd]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let subtleGlass = LinearGradient(
        gradient: Gradient(colors: [
            Color.white.opacity(0.5),
            Color.white.opacity(0.1)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - View Modifiers

struct LiquidGlassCard: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    if colorScheme == .dark {
                        Color.black.opacity(0.4)
                    } else {
                        Color.white.opacity(0.65)
                    }
                }
                .background(.ultraThinMaterial) // The key blur effect
            )
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(LinearGradient.subtleGlass, lineWidth: 1)
            )
            .shadow(color: .glassShadow, radius: 15, x: 0, y: 10)
    }
}

struct BouncyButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}

// MARK: - Extensions

extension View {
    func liquidGlass() -> some View {
        self.modifier(LiquidGlassCard())
    }
    
    func liquidBackground() -> some View {
        self.background(
            ZStack {
                Color("Background") // Fallback
                    .ignoresSafeArea()
                
                // Abstract Orbs
                GeometryReader { proxy in
                    Circle()
                        .fill(Color.royalGradientStart.opacity(0.3))
                        .blur(radius: 60)
                        .frame(width: 300, height: 300)
                        .position(x: 0, y: 0)
                    
                    Circle()
                        .fill(Color.royalGradientEnd.opacity(0.2))
                        .blur(radius: 60)
                        .frame(width: 400, height: 400)
                        .position(x: proxy.size.width, y: proxy.size.height)
                }
                .ignoresSafeArea()
            }
        )
    }
}
