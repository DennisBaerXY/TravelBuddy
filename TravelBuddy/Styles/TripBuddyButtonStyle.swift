//
//  TripBuddyButtonStyle.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 01.04.25.
//

import SwiftUI

struct TripBuddyButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding(.horizontal, 24) // Slightly more padding
			.padding(.vertical, 14) // Slightly more padding
			.background(
				RoundedRectangle(cornerRadius: 25) // More rounded corners
					.fill(configuration.isPressed ? Color.tripBuddyPrimary.opacity(0.7) : Color.tripBuddyPrimary)
			)
			.foregroundColor(.white)
			.font(.system(size: 16, weight: .medium)) // Less bold for a softer look
			.scaleEffect(configuration.isPressed ? 0.98 : 1)
			.animation(.easeInOut(duration: 0.3), value: configuration.isPressed) // Slower, more fluid animation
			.shadow(color: Color.tripBuddyPrimary.opacity(0.2), radius: 4, x: 0, y: 2) // Subtle shadow
	}
}
