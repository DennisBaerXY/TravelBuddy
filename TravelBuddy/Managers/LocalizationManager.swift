// TravelBuddy/Managers/LocalizationManager.swift
import Combine
import Foundation
import SwiftUI // Needed for Locale, ObservableObject, etc.

/// Manages app language preference and provides the corresponding Locale for the SwiftUI environment.
final class LocalizationManager: ObservableObject {
	// MARK: - Shared Instance

	static let shared = LocalizationManager()

	// MARK: - Published Properties

	/// The currently selected application language preference.
	@Published var currentLanguage: AppLanguage {
		didSet {
			// Save the preference when it changes
			UserDefaults.standard.set(currentLanguage.rawValue, forKey: languageKey)
			// Update the locale used by the environment
			updateAppLocale()
			// Optional: Log language change if needed
			// Logger.info("App language changed to: \(currentLanguage.rawValue)")
		}
	}

	/// The Locale object derived from the currentLanguage, used to set the environment.
	@Published private(set) var appLocale: Locale

	// MARK: - Private Properties

	private let languageKey = "app_language"

	// MARK: - Initialization

	private init() {
		// Get saved language or determine default
		let savedCode = UserDefaults.standard.string(forKey: languageKey) ?? AppLanguage.system.rawValue
		let initialLanguage = AppLanguage(rawValue: savedCode) ?? .system

		self.currentLanguage = initialLanguage

		// Set the initial locale based on the loaded language
		self.appLocale = LocalizationManager.locale(for: initialLanguage)

		if AppConstants.enableDebugLogging {
			print("LocalizationManager initialized. Current Language: \(currentLanguage.rawValue), App Locale: \(appLocale.identifier)")
		}
	}

	// MARK: - Public Methods

	/// Sets the app's preferred language.
	/// - Parameter language: The language to set.
	func setLanguage(_ language: AppLanguage) {
		guard language != currentLanguage else { return }
		currentLanguage = language // This triggers didSet, saving and updating locale
	}

	// MARK: - Locale Calculation (Static Helper)

	/// Determines the appropriate Locale based on the AppLanguage setting.
	/// - Parameter language: The selected AppLanguage.
	/// - Returns: The corresponding Locale object.
	private static func locale(for language: AppLanguage) -> Locale {
		if language == .system {
			// Use the system's current locale preference
			return Locale.autoupdatingCurrent
			// Or determine primary device language if needed: Locale(identifier: Locale.preferredLanguages.first ?? "en")
		} else {
			// Use the specific locale for the chosen language
			return Locale(identifier: language.rawValue)
		}
	}

	// MARK: - Locale Update

	/// Updates the published appLocale based on the currentLanguage.
	private func updateAppLocale() {
		let newLocale = LocalizationManager.locale(for: currentLanguage)
		if newLocale != appLocale {
			appLocale = newLocale
			if AppConstants.enableDebugLogging {
				print("App Locale updated to: \(appLocale.identifier)")
			}
		}
	}
}
