import SwiftUI

extension Color {
    // App background (warm, sandy yellow)
    static let appBackground = Color(hex: "F8F7F3")
    // White
    static let appCardBackground = Color(.systemBackground)
    // Main dark blue for buttons and accents
    static let appPrimaryBlue = Color(hex: "295D8C")
    // Light blue for cards and icons
    static let appSecondaryBlue = Color(hex: "DEE6ED")
    // Super dark blue for text
    static let appThirdBlue = Color(hex: "2B3A48")
    // Bright yellow for borders
    static let appCardBorder = Color(hex: "E5E7DF")
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
