import Foundation
import SwiftUI

// MARK: - Transport Types

/// Types of transportation used for a trip
enum TransportType: String, CaseIterable, Identifiable {
	case plane = "Flugzeug"
	case car = "Auto"
	case train = "Zug"
	case bus = "Bus"
	case ship = "Schiff"
	case bicycle = "Fahrrad"
	case onFoot = "Zu Fuß"
	
	var id: String { rawValue }
	
	/// System icon name representing this transport type
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
	
	/// Localized name for display
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

/// Types of accommodation for a trip
enum AccommodationType: String, CaseIterable, Identifiable {
	case hotel = "Hotel"
	case apartment = "Apartment"
	case camping = "Camping"
	case hostels = "Hostel"
	case friends = "Bei Freunden"
	case airbnb = "Airbnb"
	
	var id: String { rawValue }
	
	/// System icon name representing this accommodation type
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
	
	/// Localized name for display
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

/// Types of activities planned for a trip
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
	
	/// System icon name representing this activity
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
	
	/// Localized name for display
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

/// Categories for packing items
enum ItemCategory: String, CaseIterable, Identifiable {
	case clothing = "Kleidung"
	case documents = "Dokumente"
	case toiletries = "Toilettenartikel"
	case electronics = "Elektronik"
	case accessories = "Accessoires"
	case medication = "Medikamente"
	case other = "Sonstiges"
	
	var id: String { rawValue }
	
	/// System icon name representing this category
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
	
	/// Localized name for display
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
	
	/// Color associated with this category
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

/// Types of climate at the destination
enum Climate: String, CaseIterable, Identifiable {
	case hot = "Heiß"
	case warm = "Warm"
	case moderate = "Gemäßigt"
	case cool = "Kühl"
	case cold = "Kalt"
	
	var id: String { rawValue }
	
	/// System icon name representing this climate
	var iconName: String {
		switch self {
		case .hot: return "sun.max"
		case .warm: return "sun.min"
		case .moderate: return "cloud.sun"
		case .cool: return "wind"
		case .cold: return "snowflake"
		}
	}
	
	/// Localized name for display
	var localizedName: String {
		switch self {
		case .hot: return String(localized: "climate_hot")
		case .warm: return String(localized: "climate_warm")
		case .moderate: return String(localized: "climate_moderate")
		case .cool: return String(localized: "climate_cool")
		case .cold: return String(localized: "climate_cold")
		}
	}
	
	/// Color associated with this climate
	var color: Color {
		switch self {
		case .hot: return .red
		case .warm: return .orange
		case .moderate: return .green
		case .cool: return .blue
		case .cold: return .indigo
		}
	}
	
	/// Temperature range recommendation in Celsius
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

/// Options for sorting packing items
enum SortOption: String, CaseIterable, Identifiable {
	case name = "Name"
	case category = "Category"
	case essential = "Essential"
	case dateAdded = "Date Added"
	
	var id: String { rawValue }
	
	/// Localized name for display
	var localizedName: LocalizedStringKey {
		switch self {
		case .name: return "sort_by_name"
		case .category: return "sort_by_category"
		case .essential: return "sort_by_essential"
		case .dateAdded: return "sort_by_date"
		}
	}
	
	/// Icon name representing this sort option
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

/// Direction for sorting operations
enum SortOrder: String, CaseIterable, Identifiable {
	case ascending = "Ascending"
	case descending = "Descending"
	
	var id: String { rawValue }
	
	/// Localized name for display
	var localizedName: LocalizedStringKey {
		switch self {
		case .ascending: return "sort_ascending"
		case .descending: return "sort_descending"
		}
	}
	
	/// Icon name representing this sort order
	var iconName: String {
		switch self {
		case .ascending: return "arrow.up"
		case .descending: return "arrow.down"
		}
	}
	
	/// Toggles between ascending and descending
	mutating func toggle() {
		self = (self == .ascending) ? .descending : .ascending
	}
}

// MARK: - Trip Status

/// Status of a trip based on dates
enum TripStatus: String, Identifiable {
	case upcoming = "Upcoming"
	case active = "Active"
	case past = "Past"
	case completed = "Completed"
	
	var id: String { rawValue }
	
	/// Localized name for display
	var localizedName: LocalizedStringKey {
		switch self {
		case .upcoming: return "status_upcoming"
		case .active: return "status_active"
		case .past: return "status_past"
		case .completed: return "status_completed"
		}
	}
	
	/// Icon name representing this status
	var iconName: String {
		switch self {
		case .upcoming: return "calendar.badge.clock"
		case .active: return "calendar.badge.exclamationmark"
		case .past: return "calendar.badge.minus"
		case .completed: return "calendar.badge.checkmark"
		}
	}
	
	/// Color associated with this status
	var color: Color {
		switch self {
		case .upcoming: return .blue
		case .active: return .green
		case .past: return .orange
		case .completed: return .gray
		}
	}
}
