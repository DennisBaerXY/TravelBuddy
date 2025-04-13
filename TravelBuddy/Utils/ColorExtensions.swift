import SwiftUI

extension Bool: @retroactive Comparable {
	public static func <(lhs: Self, rhs: Self) -> Bool {
		// the only true inequality is false < true
		!lhs && rhs
	}
}

func progressColor(for value: Double) -> Color {
	// Beibehaltung der Logik oder Anpassung an neue Palette
	if value < 0.3 {
		return .tripBuddyAlert.opacity(0.8)
	} else if value < 1 {
		return .tripBuddyAccent.opacity(0.8)

	} else {
		return .tripBuddySuccess
	}
}
