//
//  SmartPackingAnimationView.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 30.04.25.
//


import SwiftUI

// MARK: - Smart Packing Animation View
// Represents the "Smart Packing" concept with SwiftUI animations.
// Add this file to your project.
struct SmartPackingAnimationView: View {
	@Environment(\.colorScheme) var colorScheme // To adapt to light/dark mode
	@State private var animate = false

	// Define colors based on your asset catalog names
	// Ensure these color assets exist in your project
	private var primaryColor: Color { Color("TripBuddyPrimary") }
	private var successColor: Color { Color("TripBuddySuccess") }
	private var accentColor: Color { Color("TripBuddyAccent") }
	private var alertColor: Color { Color("TripBuddyAlert") }
	private var textColor: Color { Color("TripBuddyText") }
	private var secondaryTextColor: Color { Color("TripBuddyTextSecondary") }


	var body: some View {
		ZStack {
			// Suitcase outline
			RoundedRectangle(cornerRadius: 15)
				.stroke(textColor.opacity(0.7), lineWidth: 3)
				.frame(width: 180, height: 220)
				.overlay(
					// Handle
					RoundedRectangle(cornerRadius: 5)
						.fill(textColor.opacity(0.7))
						.frame(width: 40, height: 10)
						.offset(y: -115) // Position handle at top
				)

			// "Brain" or "Gear" icon (symbolizing smartness)
			Image(systemName: "gearshape.fill") // Using a gear icon
				.font(.system(size: 50))
				.foregroundColor(accentColor) // Use accent color
				.rotationEffect(.degrees(animate ? 360 : 0)) // Spin effect
				.offset(y: -150) // Position above the suitcase
				.animation(.linear(duration: 4.0).repeatForever(autoreverses: false), value: animate) // Continuous spin

			// Trip Detail Icons (feeding into the "brain")
			Group {
				Image(systemName: "sun.max.fill") // Climate
					.foregroundColor(.orange) // Using a standard color, or define in assets
					.offset(x: animate ? -70 : 0, y: animate ? -100 : 0)
					.scaleEffect(animate ? 1.0 : 0.5)
					.opacity(animate ? 1.0 : 0)
					.animation(.easeOut(duration: 0.8).delay(0.5), value: animate)

				Image(systemName: "airplane") // Transport
					.foregroundColor(primaryColor)
					.offset(x: animate ? 70 : 0, y: animate ? -100 : 0)
					.scaleEffect(animate ? 1.0 : 0.5)
					.opacity(animate ? 1.0 : 0)
					.animation(.easeOut(duration: 0.8).delay(0.6), value: animate)

				Image(systemName: "briefcase.fill") // Activity (Business)
					.foregroundColor(secondaryTextColor)
					.offset(x: animate ? -50 : 0, y: animate ? -140 : 0)
					.scaleEffect(animate ? 1.0 : 0.5)
					.opacity(animate ? 1.0 : 0)
					.animation(.easeOut(duration: 0.8).delay(0.7), value: animate)
			}

			// Item Icons (flying into the suitcase)
			Group {
				Image(systemName: "passport.fill") // Document (Essential)
					.foregroundColor(alertColor) // Use alert color for essential
					.offset(x: animate ? -40 : -100, y: animate ? 50 : -100)
					.scaleEffect(animate ? 1.0 : 0.5)
					.opacity(animate ? 1.0 : 0)
					.animation(.easeOut(duration: 1.0).delay(1.0), value: animate)

				Image(systemName: "tshirt.fill") // Clothing
					.foregroundColor(primaryColor)
					.offset(x: animate ? 40 : 100, y: animate ? 60 : -100)
					.scaleEffect(animate ? 1.0 : 0.5)
					.opacity(animate ? 1.0 : 0)
					.animation(.easeOut(duration: 1.0).delay(1.1), value: animate)

				Image(systemName: "charger.fill") // Electronics
					.foregroundColor(accentColor)
					.offset(x: animate ? -20 : -100, y: animate ? 80 : -80)
					.scaleEffect(animate ? 1.0 : 0.5)
					.opacity(animate ? 1.0 : 0)
					.animation(.easeOut(duration: 1.0).delay(1.2), value: animate)

				Image(systemName: "figure.hiking") // Activity related item
					.foregroundColor(successColor)
					.offset(x: animate ? 60 : 100, y: animate ? 90 : -80)
					.scaleEffect(animate ? 1.0 : 0.5)
					.opacity(animate ? 1.0 : 0)
					.animation(.easeOut(duration: 1.0).delay(1.3), value: animate)
			}

			// Checkmark on suitcase (for completion)
			Circle()
				.fill(successColor) // Use success color
				.frame(width: 40, height: 40)
				.overlay(
					Image(systemName: "checkmark.seal.fill") // Use a seal checkmark
						.foregroundColor(.white)
						.font(.system(size: 20, weight: .bold))
				)
				.scaleEffect(animate ? 1.0 : 0.1)
				.opacity(animate ? 1.0 : 0)
				.offset(y: -60) // Position on the suitcase
				.animation(.spring(response: 0.5, dampingFraction: 0.5).delay(2.0), value: animate)
		}
		.onAppear {
			animate = true // Start animation
		}
		.onDisappear {
			animate = false // Reset animation
		}
	}
}

// MARK: - Preview
#Preview {
	SmartPackingAnimationView()
		.frame(width: 250, height: 300) // Give it a frame for preview
		.padding()
		.background(Color("TripBuddyBackground")) // Use your background color
}
