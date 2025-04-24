import Foundation
import SwiftUI

// MARK: - Transport Types

enum TransportType: String, CaseIterable, Identifiable {
	case plane = "Flugzeug"
	case car = "Auto"
	case train = "Zug"
	case bus = "Bus"
	case ship = "Schiff"
	case bicycle = "Fahrrad"
	case onFoot = "Zu Fuß"
	
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
	
	var localizedName: String {
		switch self {
		case .plane: return String(localized: "transport_plane")
		case .car: return String(localized: "transport_car")
		case .train: return String(localized: "transport_train")
		case .bus: return String(localized: "transport_bus")
		case .ship: return String(localized: "transport_ship")
		case .bicycle: return String(localized: "transport_bicycle")
		case .onFoot: return String(localized: "transport_on_foot")
		}
	}
}

// MARK: - Accommodation Types

enum AccommodationType: String, CaseIterable, Identifiable {
	case hotel = "Hotel"
	case apartment = "Apartment"
	case camping = "Camping"
	case hostels = "Hostel"
	case friends = "Bei Freunden"
	case airbnb = "Airbnb"
	
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
	
	var localizedName: String {
		switch self {
		case .hotel: return String(localized: "accommodation_hotel")
		case .apartment: return String(localized: "accommodation_apartment")
		case .camping: return String(localized: "accommodation_camping")
		case .hostels: return String(localized: "accommodation_hostel")
		case .friends: return String(localized: "accommodation_friends")
		case .airbnb: return String(localized: "accommodation_airbnb")
		}
	}
}

// MARK: - Activity Types

enum Activity: String, CaseIterable, Identifiable {
	case business = "Geschäftstermine"
	case swimming = "Schwimmen"
	case hiking = "Wandern"
	case skiing = "Skifahren"
	case sightseeing = "Sightseeing"
	case beach = "Strand"
	case sports = "Sport"
	case relaxing = "Entspannen"
	
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
	
	var localizedName: String {
		switch self {
		case .business: return String(localized: "activity_business")
		case .swimming: return String(localized: "activity_swimming")
		case .hiking: return String(localized: "activity_hiking")
		case .skiing: return String(localized: "activity_skiing")
		case .sightseeing: return String(localized: "activity_sightseeing")
		case .beach: return String(localized: "activity_beach")
		case .sports: return String(localized: "activity_sports")
		case .relaxing: return String(localized: "activity_relaxing")
		}
	}
}

// MARK: - Item Categories

enum ItemCategory: String, CaseIterable, Identifiable {
	case clothing = "Kleidung"
	case documents = "Dokumente"
	case toiletries = "Toilettenartikel"
	case electronics = "Elektronik"
	case accessories = "Accessoires"
	case medication = "Medikamente"
	case other = "Sonstiges"
	
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
		case .clothing: return String(localized: "category_clothing")
		case .documents: return String(localized: "category_documents")
		case .toiletries: return String(localized: "category_toiletries")
		case .electronics: return String(localized: "category_electronics")
		case .accessories: return String(localized: "category_accessories")
		case .medication: return String(localized: "category_medication")
		case .other: return String(localized: "category_other")
		}
	}
	
	var color: Color {
		switch self {
		case .clothing: return .blue
		case .documents: return .orange
		case .toiletries: return .green
		case .electronics: return .purple
		case .accessories: return .pink
		case .medication: return .red
		case .other: return .gray
		}
	}
}

// MARK: - Climate Types

enum Climate: String, CaseIterable, Identifiable {
	case hot = "Heiß"
	case warm = "Warm"
	case moderate = "Gemäßigt"
	case cool = "Kühl"
	case cold = "Kalt"
	
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
	
	var localizedName: String {
		switch self {
		case .hot: return String(localized: "climate_hot")
		case .warm: return String(localized: "climate_warm")
		case .moderate: return String(localized: "climate_moderate")
		case .cool: return String(localized: "climate_cool")
		case .cold: return String(localized: "climate_cold")
		}
	}
	
	var color: Color {
		switch self {
		case .hot: return .red
		case .warm: return .orange
		case .moderate: return .green
		case .cool: return .blue
		case .cold: return .indigo
		}
	}
	
	var temperatureRange: String {
		switch self {
		case .hot: return "30°C+"
		case .warm: return "25-30°C"
		case .moderate: return "15-25°C"
		case .cool: return "5-15°C"
		case .cold: return "Below 5°C"
		}
	}
}

// MARK: - Sort Options

enum SortOption: String, CaseIterable, Identifiable, Codable {
	case name = "Name"
	case category = "Category"
	case essential = "Essential"
	case dateAdded = "Date Added"
	
	var id: String { rawValue }
	
	var localizedName: LocalizedStringKey {
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

enum SortOrder: String, CaseIterable, Identifiable, Codable {
	case ascending = "Ascending"
	case descending = "Descending"
	
	var id: String { rawValue }
	
	var localizedName: LocalizedStringKey {
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
	
	mutating func toggle() {
		self = (self == .ascending) ? .descending : .ascending
	}
}

// MARK: - Trip Status

enum TripStatus: String, Identifiable {
	case upcoming = "Upcoming"
	case active = "Active"
	case past = "Past"
	case completed = "Completed"
	
	var id: String { rawValue }
	
	var localizedName: LocalizedStringKey {
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
		case .completed: return "calendar.badge.checkmark"
		}
	}
	
	var color: Color {
		switch self {
		case .upcoming: return .blue
		case .active: return .green
		case .past: return .orange
		case .completed: return .gray
		}
	}
}

// MARK: - Measurement System

/// Supported measurement systems for the app
enum MeasurementSystem: String, CaseIterable, Codable {
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
