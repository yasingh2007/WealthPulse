import SwiftUI

enum Theme {
    static let background = Color(hex: "F3F6F4")
    static let surface = Color(hex: "FFFFFF")
    static let ink = Color(hex: "1B2A24")
    static let muted = Color(hex: "5F7369")
    static let accent = Color(hex: "0F7A5F")
    static let accentSoft = Color(hex: "D8F0E7")
    static let danger = Color(hex: "C44536")
    static let warning = Color(hex: "D4A017")
    static let chartTrack = Color(hex: "E4EBE7")

    static let heroGradient = LinearGradient(
        colors: [Color(hex: "0B3D32"), Color(hex: "0F7A5F"), Color(hex: "3FAE8B")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardShadow = Color.black.opacity(0.06)
}
