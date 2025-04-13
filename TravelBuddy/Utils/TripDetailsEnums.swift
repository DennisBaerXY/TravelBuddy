//
//  TripDetailsEnums.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 13.04.25.
//

import SwiftUI // Für LocalizedStringKey

// Enum für Sortieroptionen
enum SortOption: String, CaseIterable, Identifiable {
	case name = "Name"
	// Füge hier bei Bedarf weitere Optionen hinzu (z.B. .category, .dateAdded)

	var id: String { rawValue }

	var localizedName: LocalizedStringKey {
		switch self {
		case .name: return "sort_by_name"
			// Füge hier Lokalisierungen für andere Optionen hinzu
		}
	}
}

// Enum für Sortierrichtung
enum SortOrder {
	case ascending
	case descending

	// Helfer zum Umschalten
	mutating func toggle() {
		self = (self == .ascending) ? .descending : .ascending
	}
}
