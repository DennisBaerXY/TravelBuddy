import SwiftUI

extension Color {
	// Farbdefinitionen für Light & Dark Mode-kompatible Farben
	// Diese verwenden den Asset Catalog

	// Fallback-Werte für die Vorschau und Tests
	// Diese werden nur verwendet, wenn die Asset Catalog Farben nicht verfügbar sind
	static var tripBuddyPrimaryValue: Color {
		@Environment(\.colorScheme) var colorScheme
		return colorScheme == .dark ? Color(hex: 0x5D87FF) : Color(hex: 0x3563E9)
	}
	
	static var tripBuddySuccessValue: Color {
		@Environment(\.colorScheme) var colorScheme
		return colorScheme == .dark ? Color(hex: 0x4ADE80) : Color(hex: 0x21C55D)
	}
	
	static var tripBuddyAlertValue: Color {
		@Environment(\.colorScheme) var colorScheme
		return colorScheme == .dark ? Color(hex: 0xFF7D73) : Color(hex: 0xF97066)
	}
	
	static var tripBuddyAccentValue: Color {
		@Environment(\.colorScheme) var colorScheme
		return colorScheme == .dark ? Color(hex: 0xFFB940) : Color(hex: 0xF59F00)
	}
	
	static var tripBuddyBackgroundValue: Color {
		@Environment(\.colorScheme) var colorScheme
		return colorScheme == .dark ? Color(hex: 0x121212) : Color(hex: 0xF8F9FA)
	}
	
	static var tripBuddyCardValue: Color {
		@Environment(\.colorScheme) var colorScheme
		return colorScheme == .dark ? Color(hex: 0x1E1E1E) : Color(hex: 0xFFFFFF)
	}
	
	static var tripBuddyTextValue: Color {
		@Environment(\.colorScheme) var colorScheme
		return colorScheme == .dark ? Color(hex: 0xF8F9FA) : Color(hex: 0x212529)
	}
	
	static var tripBuddyTextSecondaryValue: Color {
		@Environment(\.colorScheme) var colorScheme
		return colorScheme == .dark ? Color(hex: 0xADB5BD) : Color(hex: 0x6C757D)
	}
	
	// Hilfsfunktion für Hex-Farben
	init(hex: UInt, alpha: Double = 1) {
		self.init(
			.sRGB,
			red: Double((hex >> 16) & 0xFF) / 255,
			green: Double((hex >> 8) & 0xFF) / 255,
			blue: Double(hex & 0xFF) / 255,
			opacity: alpha
		)
	}
}

extension Bool: @retroactive Comparable {
	public static func <(lhs: Self, rhs: Self) -> Bool {
		// the only true inequality is false < true
		!lhs && rhs
	}
}
