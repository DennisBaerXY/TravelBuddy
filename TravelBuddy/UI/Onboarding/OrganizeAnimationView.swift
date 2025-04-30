//
//  OrganizeAnimationView.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 30.04.25.
//

import SwiftUI

// MARK: - Organize Animation View

// Represents the "Organize Your Trips" concept with SwiftUI animations.
// Add this file to your project.
struct OrganizeAnimationView: View {
	@Environment(\.colorScheme) var colorScheme // To adapt to light/dark mode
	@State private var animate = false

	// Define colors based on your asset catalog names
	// Ensure these color assets exist in your project
	private var primaryColor: Color { Color("TripBuddyPrimary") }
	private var accentColor: Color { Color("TripBuddyAccent") }
	private var secondaryTextColor: Color { Color("TripBuddyTextSecondary") }
	private var cardColor: Color { Color("TripBuddyCard") }

	var body: some View {
		ZStack {
			// Background container (like a stylized phone screen)
			RoundedRectangle(cornerRadius: 20)
				.fill(cardColor) // Use card background color
				.frame(width: 200, height: 250)
				.shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

			// Abstract lists/containers
			VStack(spacing: 10) {
				ForEach(0 ..< 3) { index in
					RoundedRectangle(cornerRadius: 8)
						.fill(accentColor.opacity(0.6)) // Use accent color
						.frame(width: 150, height: 30)
						.overlay(
							HStack(spacing: 5) {
								// Icon placeholder
								Circle()
									.fill(primaryColor) // Use primary color
									.frame(width: 15, height: 15)
									.scaleEffect(animate ? 1.0 : 0.5)
									.opacity(animate ? 1.0 : 0)
									.animation(.spring(response: 0.5, dampingFraction: 0.5).delay(Double(index) * 0.1 + 0.2), value: animate)

								// Text placeholder
								RoundedRectangle(cornerRadius: 2)
									.fill(Color.white.opacity(0.8))
									.frame(width: 80, height: 8)
									.scaleEffect(CGSize(width: animate ? 1.0 : 0.5, height: 1.0), anchor: .leading)
									.opacity(animate ? 1.0 : 0)
									.animation(.spring(response: 0.5, dampingFraction: 0.5).delay(Double(index) * 0.1 + 0.3), value: animate)

								Spacer()
							}
							.padding(.horizontal, 8)
						)
						.offset(x: animate ? 0 : -50) // Slide in effect
						.opacity(animate ? 1.0 : 0)
						.animation(.spring(response: 0.6, dampingFraction: 0.6).delay(Double(index) * 0.1), value: animate)
				}
			}

			// Checkmark (optional, for completion feel)
			Circle()
				.fill(Color("TripBuddySuccess")) // Use success color from assets
				.frame(width: 30, height: 30)
				.overlay(
					Image(systemName: "checkmark")
						.foregroundColor(.white)
						.font(.system(size: 15, weight: .bold))
				)
				.scaleEffect(animate ? 1.0 : 0.1)
				.opacity(animate ? 1.0 : 0)
				.offset(x: 80, y: 110) // Position the checkmark
				.animation(.spring(response: 0.5, dampingFraction: 0.5).delay(1.5), value: animate)
		}
		.onAppear {
			animate = true // Start animation when view appears
		}
		.onDisappear {
			animate = false // Reset animation when view disappears
		}
	}
}

// MARK: - Preview

#Preview {
	OrganizeAnimationView()
		.frame(width: 250, height: 300) // Give it a frame for preview
		.padding()
		.background(Color("TripBuddyBackground")) // Use your background color
}
