// TravelBuddy/Managers/UserSettingsManager.swift
import Combine
import FirebaseAnalytics
import Foundation
import SwiftUI

import UserMessagingPlatform

/// A centralized manager for user settings and preferences, leveraging @AppStorage.
final class UserSettingsManager: ObservableObject { // Mark final for performance
	// MARK: - Shared Instance

	/// Shared singleton instance (remains for potential non-SwiftUI access)
	static let shared = UserSettingsManager()

	// MARK: - Private Keys Enum

	/// Keys constants for UserDefaults storage, kept private.
	private enum Keys {
		static let hasCompletedOnboarding = "hasCompletedOnboarding"
		static let isPremiumUser = "isPremiumUser"
		static let defaultSortOption = "defaultSortOption"
		static let defaultSortOrder = "defaultSortOrder"
		static let prefersDarkMode = "prefersDarkMode" // Key for optional bool
		static let prioritizeEssentialItems = "prioritizeEssentialItems"
		static let autoSuggestPackingLists = "autoSuggestPackingLists"
		static let showCompletedTrips = "showCompletedTrips"
		static let preferredMeasurementSystem = "preferredMeasurementSystem"
		static let lastUsedDate = "lastUsedDate" // Keep if needed outside settings data
		static let preferredTravelStyle = "preferredTravelStyle"
		static let trackingRequestedKey = "has_requested_att_permission"
	}

	// MARK: - Published Properties (Using @AppStorage where possible)

	/// Whether the user has completed the onboarding.
	@AppStorage(Keys.hasCompletedOnboarding) var hasCompletedOnboarding: Bool = false

	/// Whether the user has premium access.
	@AppStorage(Keys.isPremiumUser) var isPremiumUser: Bool = false {
		didSet {
			UserDefaults.standard.set(isPremiumUser, forKey: Keys.isPremiumUser)
			// --- Set Firebase User Property ---
			if AppConstants.enableAnalytics {
				// Property names should be <= 24 chars, values <= 36 chars
				Analytics.setUserProperty(isPremiumUser ? "true" : "false",
				                          forName: "is_premium") // Custom user property name
			}
		}
	}

	@AppStorage(Keys.trackingRequestedKey) var trackingRequested: Bool = false

	@AppStorage(Keys.preferredTravelStyle) var preferredTravelStyle: TravelStyle = .unknown

	/// User's preferred sort option for packing lists. Defaults to name.
	@AppStorage(Keys.defaultSortOption) var defaultSortOption: SortOption = .name

	/// User's preferred sort order for packing lists. Defaults to ascending.
	@AppStorage(Keys.defaultSortOrder) var defaultSortOrder: SortOrder = .ascending

	/// Whether to show essential items at the top of the list. Defaults to true.
	@AppStorage(Keys.prioritizeEssentialItems) var prioritizeEssentialItems: Bool = true

	/// Whether to automatically suggest packing lists. Defaults to true.
	@AppStorage(Keys.autoSuggestPackingLists) var autoSuggestPackingLists: Bool = true

	/// Whether to show completed trips in the main list. Defaults to true.
	@AppStorage(Keys.showCompletedTrips) var showCompletedTrips: Bool = true

	/// The user's preferred measurement system. Defaults based on locale.
	@AppStorage(Keys.preferredMeasurementSystem) var preferredMeasurementSystem: MeasurementSystem = {
		// Default logic based on system locale if not set
		Locale.current.measurementSystem == .metric ? .metric : .imperial
	}()

	/// User's preference for dark mode (nil means follow system).
	/// Needs custom handling because @AppStorage doesn't directly support Optional<Bool>.
	@Published var prefersDarkMode: Bool? {
		didSet {
			// Save manually to UserDefaults
			if let value = prefersDarkMode {
				UserDefaults.standard.set(value, forKey: Keys.prefersDarkMode)
			} else {
				UserDefaults.standard.removeObject(forKey: Keys.prefersDarkMode)
			}
		}
	}

	// MARK: - Initialization

	/// Private initializer to enforce singleton pattern and load custom properties.
	private init() {
		// Load the optional prefersDarkMode manually
		if UserDefaults.standard.object(forKey: Keys.prefersDarkMode) != nil {
			self.prefersDarkMode = UserDefaults.standard.bool(forKey: Keys.prefersDarkMode)
		} else {
			self.prefersDarkMode = nil // Use system setting
		}

		// Update last used date on initialization
		UserDefaults.standard.set(Date(), forKey: Keys.lastUsedDate)
	}

	// MARK: - Public Methods

	/// Resets all user settings managed by @AppStorage and custom ones to their default values.
	func resetAllSettings() {
		// @AppStorage vars reset automatically when their key is removed or set to default
		UserDefaults.standard.removeObject(forKey: Keys.hasCompletedOnboarding)
		UserDefaults.standard.removeObject(forKey: Keys.isPremiumUser)
		UserDefaults.standard.removeObject(forKey: Keys.defaultSortOption)
		UserDefaults.standard.removeObject(forKey: Keys.defaultSortOrder)
		UserDefaults.standard.removeObject(forKey: Keys.prioritizeEssentialItems)
		UserDefaults.standard.removeObject(forKey: Keys.autoSuggestPackingLists)
		UserDefaults.standard.removeObject(forKey: Keys.showCompletedTrips)
		UserDefaults.standard.removeObject(forKey: Keys.preferredMeasurementSystem)

		UserDefaults.standard.removeObject(forKey: Keys.prefersDarkMode)
		UserDefaults.standard.removeObject(forKey: Keys.trackingRequestedKey)

		UserDefaults.standard.removeObject(forKey: Keys.preferredTravelStyle)

		// Manually trigger updates for @Published vars if needed, though @AppStorage handles its own
		// Reset prefersDarkMode explicitly
		prefersDarkMode = nil

		// Re-apply defaults (AppStorage does this implicitly, but good for clarity)
		hasCompletedOnboarding = false
		isPremiumUser = false
		defaultSortOption = .name
		defaultSortOrder = .ascending
		prioritizeEssentialItems = true
		autoSuggestPackingLists = true
		showCompletedTrips = true
		preferredMeasurementSystem = Locale.current.measurementSystem == .metric ? .metric : .imperial
		trackingRequested = false

		ConsentInformation.shared.reset()

		// Need to manually update the @AppStorage properties if they don't automatically pick up the removal
		// by assigning their default values again to trigger updates.
		objectWillChange.send() // Notify subscribers of potential bulk change
	}

	/// Resets only the onboarding flag (for testing/development).
	func resetOnboarding() {
		hasCompletedOnboarding = false // Directly sets the @AppStorage value
		// Replace print with proper logging
		// Logger.debug("Onboarding has been reset")
		if AppConstants.enableDebugLogging {
			print("UserSettingsManager: Onboarding has been reset")
		}
	}

	/// Returns the date when the app was last used.
	func getLastUsedDate() -> Date? {
		return UserDefaults.standard.object(forKey: Keys.lastUsedDate) as? Date
	}

	// MARK: - Import/Export using Codable
}
