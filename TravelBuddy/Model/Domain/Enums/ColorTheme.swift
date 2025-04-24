//
//  ColorTheme.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//

import SwiftUI
enum ColorTheme: String, CaseIterable, Identifiable {
	case standard
	case ocean

	var id: String { rawValue }

	var displayName: String {
		switch self {
		case .standard: return NSLocalizedString("Standard", comment: "Color theme name")
		case .ocean: return NSLocalizedString("Ocean", comment: "Color theme name")
		}
	}

	// --- Return Asset Catalog Names ---
	var primaryColorName: String {
		switch self {
		case .standard: return "TripBuddyPrimary"
		case .ocean: return "OceanPrimary" // Ensure "OceanPrimary" exists in Assets
		}
	}

	var accentColorName: String {
		switch self {
		case .standard: return "TripBuddyAccent"
		case .ocean: return "OceanAccent"
		}
	}

	var successColorName: String {
		switch self {
		case .standard: return "TripBuddySuccess"
		case .ocean: return "OceanSuccess" // Or maybe share TripBuddySuccess? Decide per theme.
		}
	}

	var alertColorName: String {
		switch self {
		case .standard: return "TripBuddyAlert"
		case .ocean: return "OceanAlert"
		}
	}

	var backgroundColorName: String {
		switch self {
		case .standard: return "TripBuddyBackground"
		case .ocean: return "OceanBackground"
		}
	}

	var cardColorName: String {
		switch self {
		case .standard: return "TripBuddyCard"
		case .ocean: return "OceanCard"
		}
	}

	var textColorName: String {
		switch self {
		case .standard: return "TripBuddyText"
		case .ocean: return "OceanText"
		}
	}

	var textSecondaryColorName: String {
		switch self {
		case .standard: return "TripBuddyTextSecondary"
		case .ocean: return "OceanTextSecondary"
		}
	}
}
