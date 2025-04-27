//
//  ViewStyles.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//

import SwiftUI

extension View {
	// MARK: - Layout Modifiers

	/// Applies standard screen padding to a view.
	func screenPadding() -> some View {
		self.padding(AppConstants.screenPadding)
	}

	/// Applies the standard card style (background, corner radius, shadow) to a view.
	func cardStyle() -> some View {
		// Accessing Card color directly from Asset Catalog as it might be fundamental
		// Or, if card color should be themeable, use ThemeManager
		self
			.background(Color("TripBuddyCard")) // Or use themeManager.colorTheme.card
			.cornerRadius(AppConstants.cornerRadius)
			.shadow(
				color: Color("TripBuddyText").opacity(0.08), // Shadow color might be themeable too
				radius: AppConstants.shadowRadius / 2,
				x: 0,
				y: 2
			)
	}
}
