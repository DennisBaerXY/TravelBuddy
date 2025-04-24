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
			// Update UserSettingsManager if needed (or handle persistence here)
			syncColorSchemePreferenceToSettings()
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

		// Subscribe to UserSettingsManager's prefersDarkMode changes
		// Note: Ensure UserSettingsManager is initialized before ThemeManager if not using singletons strictly
		// Since both are initialized as @StateObject in App, this direct observation is okay.
		UserSettingsManager.shared.$prefersDarkMode
			.sink { [weak self] preference in
				guard let self = self else { return }
				let newPreference: ColorSchemePreference
				if let prefersDark = preference {
					newPreference = prefersDark ? .dark : .light
				} else {
					newPreference = .system
				}
				// Update only if the derived preference is different
				if newPreference != self.colorSchemePreference {
					self.colorSchemePreference = newPreference
				}
			}
			.store(in: &cancellables)
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
		if let prefersDark = UserSettingsManager.shared.prefersDarkMode {
			colorSchemePreference = prefersDark ? .dark : .light
		} else {
			colorSchemePreference = .system
		}
	}

	/// Updates the UserSettingsManager when the preference changes here.
	private func syncColorSchemePreferenceToSettings() {
		switch colorSchemePreference {
		case .light:
			UserSettingsManager.shared.prefersDarkMode = false
		case .dark:
			UserSettingsManager.shared.prefersDarkMode = true
		case .system:
			UserSettingsManager.shared.prefersDarkMode = nil
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
	}
}
