//
//  ThemeManager.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//
import Combine
import SwiftUI

/// Manages the app's visual theme including color theme selection and base text style.
final class ThemeManager: ObservableObject {
	// MARK: - Shared Instance

	static let shared = ThemeManager()

	// MARK: - Published Properties

	/// The currently selected color theme identifier. Changes trigger UI updates via computed color properties.
	@Published var colorTheme: ColorTheme = .standard {
		didSet {
			// Optional: Persist selected theme if desired
			// UserDefaults.standard.set(colorTheme.rawValue, forKey: "selectedTheme")
			// Logger.info("Color theme changed to: \(colorTheme.rawValue)")
		}
	}

	/// The currently selected base text style identifier.
	@Published var textStyle: TextStyle = .default {
		didSet {
			// Optional: Persist selected text style if desired
			// UserDefaults.standard.set(textStyle.rawValue, forKey: "selectedTextStyle")
			// Logger.info("Text style changed to: \(textStyle.rawValue)")
		}
	}

	/// User's preference for light/dark mode.
	@Published var colorSchemePreference: ColorSchemePreference = .system {
		didSet {
			// Update UserSettingsManager asynchronously to avoid "Publishing changes from within view updates" error
			// The syncColorSchemePreferenceToSettings function now just contains the logic to write to UserSettingsManager
			syncColorSchemePreferenceToSettings() // This is safe because syncColorSchemePreferenceToSettings uses DispatchQueue.main.async
			updateEffectiveColorScheme() // Update the scheme used by the app
			// Logger.info("Color scheme preference changed to: \(colorSchemePreference.rawValue)")
		}
	}

	/// The effective ColorScheme (light/dark/nil) derived from the preference. Used by the App struct.
	@Published private(set) var colorScheme: ColorScheme?

	// MARK: - Computed Theme Properties (Loading Named Colors)

	// These properties dynamically return the correct color based on the selected theme
	var primaryColor: Color { Color(colorTheme.primaryColorName) }
	var accentColor: Color { Color(colorTheme.accentColorName) }
	var successColor: Color { Color(colorTheme.successColorName) }
	var alertColor: Color { Color(colorTheme.alertColorName) }
	var backgroundColor: Color { Color(colorTheme.backgroundColorName) }
	var cardColor: Color { Color(colorTheme.cardColorName) }
	var textColor: Color { Color(colorTheme.textColorName) }
	var textSecondaryColor: Color { Color(colorTheme.textSecondaryColorName) }

	// MARK: - Computed Font Properties

	// Example: Provide easy access to themed fonts
	var titleFont: Font {
		// Ensure custom fonts like "Georgia" are added to the project and Info.plist
		if textStyle.titleFont == "system" {
			return .system(size: textStyle.titleSize, weight: textStyle.titleWeight)
		} else {
			return .custom(textStyle.titleFont, size: textStyle.titleSize).weight(textStyle.titleWeight)
		}
	}

	// MARK: - Private Properties

	private var cancellables = Set<AnyCancellable>()

	// MARK: - Initialization

	private init() {
		// Load persisted theme/style preferences if implemented
		// if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
		//    let theme = ColorTheme(rawValue: savedTheme) {
		//     self.colorTheme = theme
		// }
		// if let savedStyle = UserDefaults.standard.string(forKey: "selectedTextStyle"),
		//    let style = TextStyle(rawValue: savedStyle) {
		//     self.textStyle = style
		// }

		// Load initial color scheme preference from UserSettingsManager
		loadInitialColorSchemePreference()
		updateEffectiveColorScheme() // Set initial effective scheme

		// REMOVED: Sink observing UserSettingsManager.shared.$prefersDarkMode
		// ThemeManager should be the source of truth for the active preference,
		// and update UserSettingsManager, not observe it for this property.
	}

	// MARK: - Methods

	/// Determines the effective ColorScheme (light/dark/nil) based on the current preference.
	private func updateEffectiveColorScheme() {
		switch colorSchemePreference {
		case .light:
			colorScheme = .light
		case .dark:
			colorScheme = .dark
		case .system:
			colorScheme = nil // Use system setting
		}
		if AppConstants.enableDebugLogging {
			print("Effective color scheme updated to: \(String(describing: colorScheme))")
		}
	}

	/// Loads the initial preference from UserSettingsManager during init.
	private func loadInitialColorSchemePreference() {
		// Use DispatchQueue.main.async to ensure UserSettingsManager is fully initialized
		DispatchQueue.main.async {
			if let prefersDark = UserSettingsManager.shared.prefersDarkMode {
				self.colorSchemePreference = prefersDark ? .dark : .light
			} else {
				self.colorSchemePreference = .system
			}
		}
	}

	/// Updates the UserSettingsManager when the preference changes here.
	private func syncColorSchemePreferenceToSettings() {
		// Dispatch asynchronously to avoid publishing changes during view updates
		DispatchQueue.main.async {
			switch self.colorSchemePreference {
			case .light:
				UserSettingsManager.shared.prefersDarkMode = false
			case .dark:
				UserSettingsManager.shared.prefersDarkMode = true
			case .system:
				UserSettingsManager.shared.prefersDarkMode = nil
			}
		}
	}

	// Public setters remain the same if needed for UI controls
	func setColorTheme(_ theme: ColorTheme) {
		colorTheme = theme
	}

	func setTextStyle(_ style: TextStyle) {
		textStyle = style
	}

	func setColorSchemePreference(_ preference: ColorSchemePreference) {
		// This setter will trigger the didSet logic above
		colorSchemePreference = preference
		// The didSet now calls syncColorSchemePreferenceToSettings, which is async.
	}
}
