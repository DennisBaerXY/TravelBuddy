//
//  TripBuddyOutlineButtonStyle.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 13.04.25.
//

import SwiftUI
struct TripBuddyOutlineButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.headline.weight(.medium))
			.padding(.horizontal, 20)
			.padding(.vertical, 12)
			.foregroundColor(.tripBuddyPrimary) // Hauptfarbe für Text/Icon
			.background(
				Capsule() // Passend zum Filled Style
					.stroke(Color.tripBuddyPrimary, lineWidth: 1.5) // Rand in Hauptfarbe
			)
			.opacity(configuration.isPressed ? 0.7 : 1.0)
			.animation(.easeOut(duration: 0.15), value: configuration.isPressed)
	}
}
