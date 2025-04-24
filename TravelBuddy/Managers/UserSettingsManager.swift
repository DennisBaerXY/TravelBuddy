import Combine
import Foundation

/// A centralized manager for user settings and preferences
class UserSettingsManager: ObservableObject {
	// MARK: - Shared Instance
	
	/// Shared singleton instance
	static let shared = UserSettingsManager()
	
	// MARK: - Published Properties
	
	/// Whether the user has completed the onboarding
	@Published var hasCompletedOnboarding: Bool {
		didSet {
			userDefaults.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding)
		}
	}
	
	/// Whether the user has premium access
	@Published var isPremiumUser: Bool {
		didSet {
			userDefaults.set(isPremiumUser, forKey: Keys.isPremiumUser)
		}
	}
	
	/// User's preferred sort option for packing lists
	@Published var defaultSortOption: SortOption {
		didSet {
			userDefaults.set(defaultSortOption.rawValue, forKey: Keys.defaultSortOption)
		}
	}
	
	/// User's preferred sort order for packing lists
	@Published var defaultSortOrder: SortOrder {
		didSet {
			userDefaults.set(defaultSortOrder == .ascending ? "ascending" : "descending", forKey: Keys.defaultSortOrder)
		}
	}
	
	/// Whether the user prefers dark mode
	@Published var prefersDarkMode: Bool? {
		didSet {
			if let prefersDarkMode = prefersDarkMode {
				userDefaults.set(prefersDarkMode, forKey: Keys.prefersDarkMode)
			} else {
				userDefaults.removeObject(forKey: Keys.prefersDarkMode)
			}
		}
	}
	
	/// Whether to show essential items at the top of the list
	@Published var prioritizeEssentialItems: Bool {
		didSet {
			userDefaults.set(prioritizeEssentialItems, forKey: Keys.prioritizeEssentialItems)
		}
	}
	
	/// Whether to automatically suggest packing lists
	@Published var autoSuggestPackingLists: Bool {
		didSet {
			userDefaults.set(autoSuggestPackingLists, forKey: Keys.autoSuggestPackingLists)
		}
	}
	
	/// Whether to show completed trips in the main list
	@Published var showCompletedTrips: Bool {
		didSet {
			userDefaults.set(showCompletedTrips, forKey: Keys.showCompletedTrips)
		}
	}
	
	/// The user's preferred measurement system
	@Published var preferredMeasurementSystem: MeasurementSystem {
		didSet {
			userDefaults.set(preferredMeasurementSystem.rawValue, forKey: Keys.preferredMeasurementSystem)
		}
	}
	
	// MARK: - Private Properties
	
	/// UserDefaults instance for storing settings
	private let userDefaults: UserDefaults
	
	/// Key constants for UserDefaults storage
	private enum Keys {
		static let hasCompletedOnboarding = "hasCompletedOnboarding"
		static let isPremiumUser = "isPremiumUser"
		static let defaultSortOption = "defaultSortOption"
		static let defaultSortOrder = "defaultSortOrder"
		static let prefersDarkMode = "prefersDarkMode"
		static let prioritizeEssentialItems = "prioritizeEssentialItems"
		static let autoSuggestPackingLists = "autoSuggestPackingLists"
		static let showCompletedTrips = "showCompletedTrips"
		static let preferredMeasurementSystem = "preferredMeasurementSystem"
		static let lastUsedDate = "lastUsedDate"
	}
	
	// MARK: - Initialization
	
	/// Creates a new UserSettingsManager with the specified UserDefaults
	/// - Parameter userDefaults: The UserDefaults instance to use (defaults to standard)
	init(userDefaults: UserDefaults = .standard) {
		self.userDefaults = userDefaults
		
		// Initialize properties from UserDefaults
		self.hasCompletedOnboarding = userDefaults.bool(forKey: Keys.hasCompletedOnboarding)
		self.isPremiumUser = userDefaults.bool(forKey: Keys.isPremiumUser)
		
		// Initialize sort preferences
		if let sortOptionString = userDefaults.string(forKey: Keys.defaultSortOption),
		   let sortOption = SortOption(rawValue: sortOptionString)
		{
			self.defaultSortOption = sortOption
		} else {
			self.defaultSortOption = .name
		}
		
		let sortOrderString = userDefaults.string(forKey: Keys.defaultSortOrder)
		self.defaultSortOrder = sortOrderString == "descending" ? .descending : .ascending
		
		// Initialize appearance preferences
		if userDefaults.object(forKey: Keys.prefersDarkMode) != nil {
			self.prefersDarkMode = userDefaults.bool(forKey: Keys.prefersDarkMode)
		} else {
			self.prefersDarkMode = nil // Use system setting
		}
		
		// Initialize other preferences with defaults if not set
		self.prioritizeEssentialItems = userDefaults.object(forKey: Keys.prioritizeEssentialItems) != nil ?
			userDefaults.bool(forKey: Keys.prioritizeEssentialItems) : true
		
		self.autoSuggestPackingLists = userDefaults.object(forKey: Keys.autoSuggestPackingLists) != nil ?
			userDefaults.bool(forKey: Keys.autoSuggestPackingLists) : true
		
		self.showCompletedTrips = userDefaults.object(forKey: Keys.showCompletedTrips) != nil ?
			userDefaults.bool(forKey: Keys.showCompletedTrips) : true
		
		// Initialize measurement system preference
		if let systemString = userDefaults.string(forKey: Keys.preferredMeasurementSystem),
		   let system = MeasurementSystem(rawValue: systemString)
		{
			self.preferredMeasurementSystem = system
		} else {
			// Default to system locale based choice
			let locale = Locale.current
			if locale.measurementSystem == .metric {
				self.preferredMeasurementSystem = .metric
			} else {
				self.preferredMeasurementSystem = .imperial
			}
		}
		
		// Update last used date
		userDefaults.set(Date(), forKey: Keys.lastUsedDate)
	}
	
	// MARK: - Public Methods
	
	/// Resets all user settings to their default values
	func resetAllSettings() {
		hasCompletedOnboarding = false
		isPremiumUser = false
		defaultSortOption = .name
		defaultSortOrder = .ascending
		prefersDarkMode = nil
		prioritizeEssentialItems = true
		autoSuggestPackingLists = true
		showCompletedTrips = true
		
		let locale = Locale.current
		preferredMeasurementSystem = locale.measurementSystem == .metric ? .metric : .imperial
	}
	
	/// Resets only the onboarding flag (for testing/development)
	func resetOnboarding() {
		hasCompletedOnboarding = false
		if AppConstants.enableDebugLogging {
			print("Onboarding has been reset")
		}
	}
	
	/// Returns the date when the app was last used
	func getLastUsedDate() -> Date? {
		return userDefaults.object(forKey: Keys.lastUsedDate) as? Date
	}
	
	/// Exports the user settings as a dictionary
	func exportSettings() -> [String: Any] {
		[
			Keys.hasCompletedOnboarding: hasCompletedOnboarding,
			Keys.isPremiumUser: isPremiumUser,
			Keys.defaultSortOption: defaultSortOption.rawValue,
			Keys.defaultSortOrder: defaultSortOrder == .ascending ? "ascending" : "descending",
			Keys.prefersDarkMode: prefersDarkMode as Any,
			Keys.prioritizeEssentialItems: prioritizeEssentialItems,
			Keys.autoSuggestPackingLists: autoSuggestPackingLists,
			Keys.showCompletedTrips: showCompletedTrips,
			Keys.preferredMeasurementSystem: preferredMeasurementSystem.rawValue
		]
	}
	
	/// Imports user settings from a dictionary
	/// - Parameter settings: Dictionary of settings to import
	func importSettings(from settings: [String: Any]) {
		if let value = settings[Keys.hasCompletedOnboarding] as? Bool {
			hasCompletedOnboarding = value
		}
		
		if let value = settings[Keys.isPremiumUser] as? Bool {
			isPremiumUser = value
		}
		
		if let value = settings[Keys.defaultSortOption] as? String,
		   let sortOption = SortOption(rawValue: value)
		{
			defaultSortOption = sortOption
		}
		
		if let value = settings[Keys.defaultSortOrder] as? String {
			defaultSortOrder = value == "descending" ? .descending : .ascending
		}
		
		if let value = settings[Keys.prefersDarkMode] as? Bool {
			prefersDarkMode = value
		}
		
		if let value = settings[Keys.prioritizeEssentialItems] as? Bool {
			prioritizeEssentialItems = value
		}
		
		if let value = settings[Keys.autoSuggestPackingLists] as? Bool {
			autoSuggestPackingLists = value
		}
		
		if let value = settings[Keys.showCompletedTrips] as? Bool {
			showCompletedTrips = value
		}
		
		if let value = settings[Keys.preferredMeasurementSystem] as? String,
		   let system = MeasurementSystem(rawValue: value)
		{
			preferredMeasurementSystem = system
		}
	}
}

// MARK: - Measurement System

/// Supported measurement systems for the app
enum MeasurementSystem: String, CaseIterable {
	case metric
	case imperial
	
	/// Returns the appropriate weight unit (kg or lb)
	var weightUnit: String {
		switch self {
		case .metric: return "kg"
		case .imperial: return "lb"
		}
	}
	
	/// Returns the appropriate distance unit (km or mi)
	var distanceUnit: String {
		switch self {
		case .metric: return "km"
		case .imperial: return "mi"
		}
	}
	
	/// Returns the appropriate temperature unit (°C or °F)
	var temperatureUnit: String {
		switch self {
		case .metric: return "°C"
		case .imperial: return "°F"
		}
	}
	
	/// Converts a weight value from the system's unit to the other system
	/// - Parameter value: The weight value to convert
	/// - Returns: The converted weight value
	func convertWeight(_ value: Double) -> Double {
		switch self {
		case .metric: return value * 2.20462 // kg to lb
		case .imperial: return value * 0.453592 // lb to kg
		}
	}
	
	/// Converts a distance value from the system's unit to the other system
	/// - Parameter value: The distance value to convert
	/// - Returns: The converted distance value
	func convertDistance(_ value: Double) -> Double {
		switch self {
		case .metric: return value * 0.621371 // km to mi
		case .imperial: return value * 1.60934 // mi to km
		}
	}
	
	/// Converts a temperature value from the system's unit to the other system
	/// - Parameter value: The temperature value to convert
	/// - Returns: The converted temperature value
	func convertTemperature(_ value: Double) -> Double {
		switch self {
		case .metric: return value * 9/5 + 32 // °C to °F
		case .imperial: return (value - 32) * 5/9 // °F to °C
		}
	}
}
