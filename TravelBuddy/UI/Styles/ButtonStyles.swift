//
//  ButtonStyles.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//

import SwiftUI

/// A collection of custom button styles used throughout the application
/// These styles ensure a consistent look and feel across all buttons

// MARK: - Primary Button Style (Filled)

/// A primary button style with a filled background and rounded corners
struct PrimaryButtonStyle: ButtonStyle {
	var isWide = false

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.headline.weight(.semibold))
			.padding(.horizontal, 25)
			.padding(.vertical, 15)
			.frame(maxWidth: isWide ? .infinity : nil)
			.background(Color.tripBuddyPrimary)
			.foregroundColor(.white)
			.clipShape(Capsule())
			.scaleEffect(configuration.isPressed ? 0.97 : 1.0)
			.opacity(configuration.isPressed ? 0.9 : 1.0)
			.animation(.easeOut(duration: 0.15), value: configuration.isPressed)
	}
}

// MARK: - Secondary Button Style (Outline)

/// A secondary button style with an outline and no background
struct SecondaryButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.headline.weight(.medium))
			.padding(.horizontal, 20)
			.padding(.vertical, 12)
			.foregroundColor(.tripBuddyPrimary)
			.background(
				Capsule()
					.stroke(Color.tripBuddyPrimary, lineWidth: 1.5)
			)
			.opacity(configuration.isPressed ? 0.7 : 1.0)
			.animation(.easeOut(duration: 0.15), value: configuration.isPressed)
	}
}

// MARK: - Tertiary Button Style (Text Only)

/// A tertiary button style with no background or outline, just colored text
struct TertiaryButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.subheadline.weight(.medium))
			.foregroundColor(.tripBuddyPrimary)
			.opacity(configuration.isPressed ? 0.7 : 1.0)
			.animation(.easeOut(duration: 0.15), value: configuration.isPressed)
	}
}

// MARK: - Icon Button Style

/// A button style for icon-only buttons
struct IconButtonStyle: ButtonStyle {
	var backgroundColor: Color = .tripBuddyPrimary
	var size: CGFloat = 44

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.system(size: size * 0.4, weight: .semibold))
			.foregroundColor(.white)
			.frame(width: size, height: size)
			.background(backgroundColor)
			.clipShape(Circle())
			.scaleEffect(configuration.isPressed ? 0.9 : 1.0)
			.opacity(configuration.isPressed ? 0.8 : 1.0)
			.shadow(color: backgroundColor.opacity(0.3), radius: 4, x: 0, y: 2)
			.animation(.easeOut(duration: 0.15), value: configuration.isPressed)
	}
}

// MARK: - Toggle Button Style

/// A button style that appears as a toggleable option
struct ToggleButtonStyle: ButtonStyle {
	var isSelected: Bool
	var color: Color = .tripBuddyPrimary

	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.padding(.vertical, 10)
			.padding(.horizontal, 16)
			.background(
				RoundedRectangle(cornerRadius: 10)
					.fill(isSelected ? color.opacity(0.1) : Color.clear)
			)
			.overlay(
				RoundedRectangle(cornerRadius: 10)
					.stroke(isSelected ? color : Color.gray.opacity(0.5), lineWidth: isSelected ? 2 : 1)
			)
			.foregroundColor(isSelected ? color : .tripBuddyTextSecondary)
			.scaleEffect(configuration.isPressed ? 0.97 : 1.0)
			.animation(.easeOut(duration: 0.15), value: configuration.isPressed)
	}
}

// MARK: - Extensions for SwiftUI View

extension View {
	/// Applies the primary button style
	/// - Parameter isWide: Whether the button should take up the full width
	/// - Returns: A view with the primary button style applied
	func primaryButtonStyle(isWide: Bool = false) -> some View {
		buttonStyle(PrimaryButtonStyle(isWide: isWide))
	}

	/// Applies the secondary button style
	/// - Returns: A view with the secondary button style applied
	func secondaryButtonStyle() -> some View {
		buttonStyle(SecondaryButtonStyle())
	}

	/// Applies the tertiary button style
	/// - Returns: A view with the tertiary button style applied
	func tertiaryButtonStyle() -> some View {
		buttonStyle(TertiaryButtonStyle())
	}

	/// Applies the icon button style
	/// - Parameters:
	///   - backgroundColor: The background color of the button
	///   - size: The size of the button
	/// - Returns: A view with the icon button style applied
	func iconButtonStyle(backgroundColor: Color = .tripBuddyPrimary, size: CGFloat = 44) -> some View {
		buttonStyle(IconButtonStyle(backgroundColor: backgroundColor, size: size))
	}

	/// Applies the toggle button style
	/// - Parameters:
	///   - isSelected: Whether the button is selected
	///   - color: The color to use for the selected state
	/// - Returns: A view with the toggle button style applied
	func toggleButtonStyle(isSelected: Bool, color: Color = .tripBuddyPrimary) -> some View {
		buttonStyle(ToggleButtonStyle(isSelected: isSelected, color: color))
	}
}
