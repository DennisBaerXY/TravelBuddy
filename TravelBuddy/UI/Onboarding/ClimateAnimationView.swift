//
//  ClimateAnimationView.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 30.04.25.
//


import SwiftUI

struct ClimateAnimationView: View {
	@Environment(\.colorScheme) var colorScheme
	@State private var animateSun = false
	@State private var animateSnow = false
	@State private var animateRain = false

	// Define colors based on your asset catalog names
	private var primaryColor: Color { Color("TripBuddyPrimary") }
	private var accentColor: Color { Color("TripBuddyAccent") }
	private var successColor: Color { Color("TripBuddySuccess") }
	private var alertColor: Color { Color("TripBuddyAlert") }
	private var textColor: Color { Color("TripBuddyText") }

	var body: some View {
		ZStack {
			// Optional: Background element if needed, similar to other animations
			// Example: A subtle card background or gradient

			VStack(spacing: 40) { // Arrange icons vertically with spacing
				HStack(spacing: 40) {
					// Sun Icon
					Image(systemName: "sun.max.fill")
						.resizable()
						.scaledToFit()
						.frame(width: 60, height: 60)
						.foregroundColor(.orange) // Representing hot/sunny
						.scaleEffect(animateSun ? 1.2 : 0.8) // Scale animation
						.opacity(animateSun ? 1.0 : 0.5)
						.animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateSun)

					// Snow Icon
					Image(systemName: "snowflake")
						.resizable()
						.scaledToFit()
						.frame(width: 60, height: 60)
						.foregroundColor(.blue) // Representing cold/snowy
						.scaleEffect(animateSnow ? 1.2 : 0.8) // Scale animation
						.opacity(animateSnow ? 1.0 : 0.5)
						.animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.5), value: animateSnow) // Delayed animation
				}

				// Rain Icon
				Image(systemName: "cloud.rain.fill")
					.resizable()
					.scaledToFit()
					.frame(width: 60, height: 60)
					.foregroundColor(.gray) // Representing cool/rainy
					.scaleEffect(animateRain ? 1.2 : 0.8) // Scale animation
					.opacity(animateRain ? 1.0 : 0.5)
					.animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(1.0), value: animateRain) // Further delayed animation
			}
		}
		.onAppear {
			// Trigger animations when the view appears
			animateSun = true
			animateSnow = true
			animateRain = true
		}
		.onDisappear {
			// Reset animation state when the view disappears
			animateSun = false
			animateSnow = false
			animateRain = false
		}
	}
}

// MARK: - Preview

#Preview {
	ClimateAnimationView()
		.frame(width: 300, height: 300)
		.background(Color("TripBuddyBackground")) // Use your app's background color
}