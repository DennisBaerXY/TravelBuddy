import SwiftUI

extension Color {
	// Primary color - shifting from bright blue to a calmer blue-teal
	static var tripBuddyPrimaryValue: Color {
		@Environment(\.colorScheme) var colorScheme
		return colorScheme == .dark ? Color(hex: 0x5A9EA4) : Color(hex: 0x3A8A94)
	}
		
	// Success color - softer, less intense green
	static var tripBuddySuccessValue: Color {
		@Environment(\.colorScheme) var colorScheme
		return colorScheme == .dark ? Color(hex: 0x7AC1A4) : Color(hex: 0x5AAD8A)
	}
		
	// Alert color - warmer, less alarming
	static var tripBuddyAlertValue: Color {
		@Environment(\.colorScheme) var colorScheme
		return colorScheme == .dark ? Color(hex: 0xE5A17E) : Color(hex: 0xD48E69)
	}
		
	// Accent color - warmer amber tone
	static var tripBuddyAccentValue: Color {
		@Environment(\.colorScheme) var colorScheme
		return colorScheme == .dark ? Color(hex: 0xE6C29E) : Color(hex: 0xD6AF88)
	}
		
	// Background - subtle off-white/darker gray
	static var tripBuddyBackgroundValue: Color {
		@Environment(\.colorScheme) var colorScheme
		return colorScheme == .dark ? Color(hex: 0x1D2228) : Color(hex: 0xF9F6F2)
	}
		
	// Card backgrounds - softer contrast
	static var tripBuddyCardValue: Color {
		@Environment(\.colorScheme) var colorScheme
		return colorScheme == .dark ? Color(hex: 0x2A3038) : Color(hex: 0xFFFCF8)
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
