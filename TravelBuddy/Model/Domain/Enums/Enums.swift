import Foundation
import SwiftUI

// MARK: - Transport Types

// Added Codable conformance for potential future use/consistency
enum TransportType: String, CaseIterable, Identifiable, Codable {
	// Changed raw values to stable identifiers
	case plane
	case car
	case train
	case bus
	case ship
	case bicycle
	case onFoot // Consistent casing

	var id: String { rawValue }

	var iconName: String {
		switch self {
		case .plane: return "airplane"
		case .car: return "car"
		case .train: return "tram"
		case .bus: return "bus"
		case .ship: return "ferry"
		case .bicycle: return "bicycle"
		case .onFoot: return "figure.walk"
		}
	}

	// Changed to return LocalizedStringKey
	var localizedName: String {
		switch self {
		case .plane: return "transport_plane"
		case .car: return "transport_car"
		case .train: return "transport_train"
		case .bus: return "transport_bus"
		case .ship: return "transport_ship"
		case .bicycle: return "transport_bicycle"
		case .onFoot: return "transport_on_foot"
		}
	}
}

// MARK: - Accommodation Types

// Added Codable conformance for potential future use/consistency
enum AccommodationType: String, CaseIterable, Identifiable, Codable {
	// Changed raw values to stable identifiers
	case hotel
	case apartment
	case camping
	case hostels = "hostel" // Corrected pluralization in identifier
	case friends
	case airbnb

	var id: String { rawValue }

	var iconName: String {
		switch self {
		case .hotel: return "building.2"
		case .apartment: return "house"
		case .camping: return "tent"
		case .hostels: return "bed.double"
		case .friends: return "person.2"
		case .airbnb: return "house.lodge"
		}
	}

	// Changed to return LocalizedStringKey
	var localizedName: String {
		switch self {
		case .hotel: return "accommodation_hotel"
		case .apartment: return "accommodation_apartment"
		case .camping: return "accommodation_camping"
		case .hostels: return "accommodation_hostel"
		case .friends: return "accommodation_friends"
		case .airbnb: return "accommodation_airbnb"
		}
	}
}

// MARK: - Activity Types

// Added Codable conformance for potential future use/consistency
enum Activity: String, CaseIterable, Identifiable, Codable {
	// Changed raw values to stable identifiers
	case business
	case swimming
	case hiking
	case skiing
	case sightseeing
	case beach
	case sports
	case relaxing

	var id: String { rawValue }

	var iconName: String {
		switch self {
		case .business: return "briefcase"
		case .swimming: return "figure.pool.swim"
		case .hiking: return "mountain.2"
		case .skiing: return "figure.skiing.downhill"
		case .sightseeing: return "camera"
		case .beach: return "beach.umbrella"
		case .sports: return "sportscourt"
		case .relaxing: return "wineglass"
		}
	}

	// Changed to return LocalizedStringKey
	var localizedName: String {
		switch self {
		case .business: return "activity_business"
		case .swimming: return "activity_swimming"
		case .hiking: return "activity_hiking"
		case .skiing: return "activity_skiing"
		case .sightseeing: return "activity_sightseeing"
		case .beach: return "activity_beach"
		case .sports: return "activity_sports"
		case .relaxing: return "activity_relaxing"
		}
	}
}

// MARK: - Item Categories

// Added Codable conformance (useful if categories are ever saved/synced)
enum ItemCategory: String, CaseIterable, Identifiable, Codable {
	// Changed raw values to stable identifiers
	case clothing
	case documents
	case toiletries
	case electronics
	case accessories
	case medication
	case other

	var id: String { rawValue }

	var iconName: String {
		switch self {
		case .clothing: return "tshirt"
		case .documents: return "doc.text"
		case .toiletries: return "shower"
		case .electronics: return "laptopcomputer"
		case .accessories: return "bag"
		case .medication: return "pills"
		case .other: return "ellipsis"
		}
	}

	var localizedName: String {
		switch self {
		case .clothing: return "category_clothing"
		case .documents: return "category_documents"
		case .toiletries: return "category_toiletries"
		case .electronics: return "category_electronics"
		case .accessories: return "category_accessories"
		case .medication: return "category_medication"
		case .other: return "category_other"
		}
	}
}

// MARK: - Climate Types

// Added Codable conformance for potential future use/consistency
enum Climate: String, CaseIterable, Identifiable, Codable {
	// Changed raw values to stable identifiers
	case hot
	case warm
	case moderate
	case cool
	case cold

	var id: String { rawValue }

	var iconName: String {
		switch self {
		case .hot: return "sun.max"
		case .warm: return "sun.min"
		case .moderate: return "cloud.sun"
		case .cool: return "wind"
		case .cold: return "snowflake"
		}
	}

	// Changed to return LocalizedStringKey
	var localizedName: String {
		switch self {
		case .hot: return "climate_hot"
		case .warm: return "climate_warm"
		case .moderate: return "climate_moderate"
		case .cool: return "climate_cool"
		case .cold: return "climate_cold"
		}
	}

	// Removed color property
	// var color: Color { ... } // REMOVED

	// Temperature range can stay as it's descriptive data, not UI presentation
	var temperatureRange: String {
		switch self {
		case .hot: return "30°C+" // Consider localizing this if needed
		case .warm: return "25-30°C"
		case .moderate: return "15-25°C"
		case .cool: return "5-15°C"
		case .cold: return "Below 5°C"
		}
	}
}

// MARK: - Sort Options

// Already Codable
enum SortOption: String, CaseIterable, Identifiable, Codable {
	// Raw values are already stable identifiers
	case name = "Name"
	case category = "Category"
	case essential = "Essential"
	case dateAdded = "Date Added"

	var id: String { rawValue }

	var localizedName: String {
		switch self {
		case .name: return "sort_by_name"
		case .category: return "sort_by_category"
		case .essential: return "sort_by_essential"
		case .dateAdded: return "sort_by_date"
		}
	}

	var iconName: String {
		switch self {
		case .name: return "textformat.abc"
		case .category: return "folder"
		case .essential: return "exclamationmark.triangle"
		case .dateAdded: return "calendar"
		}
	}
}

// MARK: - Sort Order

// Already Codable
enum SortOrder: String, CaseIterable, Identifiable, Codable {
	// Changed raw values to stable identifiers
	case ascending
	case descending

	var id: String { rawValue }

	var localizedName: String {
		switch self {
		case .ascending: return "sort_ascending"
		case .descending: return "sort_descending"
		}
	}

	var iconName: String {
		switch self {
		case .ascending: return "arrow.up"
		case .descending: return "arrow.down"
		}
	}

	// Keep mutating toggle
	mutating func toggle() {
		self = (self == .ascending) ? .descending : .ascending
	}

	// Added non-mutating toggled
	func toggled() -> SortOrder {
		return (self == .ascending) ? .descending : .ascending
	}
}

// MARK: - Trip Status

// This enum seems purely for display logic, Codable might not be needed unless persisted
enum TripStatus: String, Identifiable {
	// Raw values are already stable identifiers
	case upcoming = "Upcoming"
	case active = "Active"
	case past = "Past" // Assuming this might be calculated, not stored
	case completed = "Completed"

	var id: String { rawValue }

	var localizedName: String {
		switch self {
		case .upcoming: return "status_upcoming"
		case .active: return "status_active"
		case .past: return "status_past"
		case .completed: return "status_completed"
		}
	}

	var iconName: String {
		switch self {
		case .upcoming: return "calendar.badge.clock"
		case .active: return "calendar.badge.exclamationmark"
		case .past: return "calendar.badge.minus"
		case .completed: return "checkmark.seal.fill" // Changed for consistency
		}
	}

	// Removed color property
	// var color: Color { ... } // REMOVED
}

// MARK: - Measurement System

// Already Codable
enum MeasurementSystem: String, CaseIterable, Codable {
	// Raw values are already stable identifiers
	case metric
	case imperial

	// Properties are fine as they describe the system, not UI presentation
	var weightUnit: String {
		switch self {
		case .metric: return "kg"
		case .imperial: return "lb"
		}
	}

	var distanceUnit: String {
		switch self {
		case .metric: return "km"
		case .imperial: return "mi"
		}
	}

	var temperatureUnit: String {
		switch self {
		case .metric: return "°C"
		case .imperial: return "°F"
		}
	}

	// Conversion methods are utility functions related to the system
	func convertWeight(_ value: Double) -> Double {
		switch self {
		case .metric: return value * 2.20462 // kg to lb
		case .imperial: return value * 0.453592 // lb to kg
		}
	}

	func convertDistance(_ value: Double) -> Double {
		switch self {
		case .metric: return value * 0.621371 // km to mi
		case .imperial: return value * 1.60934 // mi to km
		}
	}

	func convertTemperature(_ value: Double) -> Double {
		switch self {
		case .metric: return value * 9/5 + 32 // °C to °F
		case .imperial: return (value - 32) * 5/9 // °F to °C
		}
	}
}

// MARK: - App Language

// Codable might not be needed if only used for LocalizationManager internal state
enum AppLanguage: String, CaseIterable, Identifiable {
	// Raw values are standard language codes or "system" - stable
	case system
	case english = "en"
	case german = "de"
	case spanish = "es"
	case french = "fr"
	case italian = "it"

	var id: String { rawValue }

	/// The display name of the language (using native names where appropriate)
	var displayName: String {
		switch self {
		case .system: return "System Language" // Needs localization: "language_system"
		case .english: return "English" // Needs localization: "language_english"
		case .german: return "Deutsch" // Needs localization: "language_german"
		case .spanish: return "Español" // Needs localization: "language_spanish"
		case .french: return "Français" // Needs localization: "language_french"
		case .italian: return "Italiano" // Needs localization: "language_italian"
		}
		// Consider using Locale(identifier: self.rawValue).localizedString(forLanguageCode: self.rawValue)
		// or providing LocalizedStringKey for these display names if they need to be localized themselves.
		// For simplicity here, leaving as direct strings but added comments.
	}

	/// The flag emoji for the language
	var flag: String {
		switch self {
		case .system: return "🌐"
		case .english: return "🇺🇸" // Or 🇬🇧
		case .german: return "🇩🇪"
		case .spanish: return "🇪🇸"
		case .french: return "🇫🇷"
		case .italian: return "🇮🇹"
		}
	}
}
