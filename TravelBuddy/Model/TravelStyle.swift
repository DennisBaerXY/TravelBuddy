//
//  represents.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 30.04.25.
//


import Foundation
import SwiftUI

// MARK: - New Enum for Travel Style
// This enum represents the user's preferred travel style, used for personalization.
// Add this file to your project.
enum TravelStyle: String, CaseIterable, Identifiable, Codable, LocalizedEnum {
	// Raw values for stable storage
	case unknown // Default state before selection
	case business
	case family
	case adventure
	case relaxation
	case sightseeing
	case budget
	case luxury

	var id: String { self.rawValue }

	// Localized keys for display names
	var localizedKey: String {
		switch self {
		case .unknown: return "travel_style_unknown" // You'll need to add this key to your Localizable.strings
		case .business: return "travel_style_business"
		case .family: return "travel_style_family"
		case .adventure: return "travel_style_adventure"
		case .relaxation: return "travel_style_relaxation"
		case .sightseeing: return "travel_style_sightseeing"
		case .budget: return "travel_style_budget"
		case .luxury: return "travel_style_luxury"
		}
	}

	// SF Symbols for icons
	var iconName: String {
		switch self {
		case .unknown: return "questionmark.circle"
		case .business: return "briefcase.fill"
		case .family: return "figure.family.gate"
		case .adventure: return "figure.hiking"
		case .relaxation: return "beach.umbrella.fill"
		case .sightseeing: return "camera.fill"
		case .budget: return "banknote.fill"
		case .luxury: return "crown.fill"
		}
	}
}
