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
			.padding(.horizontal, 20)
			.padding(.vertical, 12)
			.background(
				RoundedRectangle(cornerRadius: 20)
					.fill(configuration.isPressed ? Color.tripBuddyPrimary.opacity(0.8) : Color.tripBuddyPrimary)
			)
			.foregroundColor(.white)
			.font(.system(size: 16, weight: .semibold))
			.scaleEffect(configuration.isPressed ? 0.97 : 1)
			.animation(.easeOut(duration: 0.2), value: configuration.isPressed)
	}
}
