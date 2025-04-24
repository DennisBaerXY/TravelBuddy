//
//  TextStyle.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//

import Combine
import SwiftUI

/// Text style for the app
enum TextStyle: String, CaseIterable, Identifiable {
	case `default`
	case compact
	case large
	case serif
    
	var id: String { rawValue }
    
	/// Display name for the style
	var displayName: String {
		switch self {
		case .default: return "Default"
		case .compact: return "Compact"
		case .large: return "Large"
		case .serif: return "Serif"
		}
	}
    
	// MARK: - Font Names
    
	/// Font name for the body text
	var bodyFont: String {
		switch self {
		case .default: return "system"
		case .compact: return "system"
		case .large: return "system"
		case .serif: return "Georgia"
		}
	}
    
	/// Font name for the title text
	var titleFont: String {
		switch self {
		case .default: return "system"
		case .compact: return "system"
		case .large: return "system"
		case .serif: return "Georgia"
		}
	}
    
	// MARK: - Font Sizes
    
	/// Font size for the title
	var titleSize: CGFloat {
		switch self {
		case .default: return 24
		case .compact: return 20
		case .large: return 28
		case .serif: return 26
		}
	}
    
	/// Font size for the headline
	var headlineSize: CGFloat {
		switch self {
		case .default: return 18
		case .compact: return 16
		case .large: return 22
		case .serif: return 20
		}
	}
    
	/// Font size for the body
	var bodySize: CGFloat {
		switch self {
		case .default: return 16
		case .compact: return 14
		case .large: return 18
		case .serif: return 16
		}
	}
    
	/// Font size for the caption
	var captionSize: CGFloat {
		switch self {
		case .default: return 12
		case .compact: return 10
		case .large: return 14
		case .serif: return 12
		}
	}
    
	// MARK: - Font Weights
    
	/// Font weight for the title
	var titleWeight: Font.Weight {
		switch self {
		case .default: return .bold
		case .compact: return .bold
		case .large: return .bold
		case .serif: return .semibold
		}
	}
    
	/// Font weight for the headline
	var headlineWeight: Font.Weight {
		switch self {
		case .default: return .semibold
		case .compact: return .semibold
		case .large: return .semibold
		case .serif: return .medium
		}
	}
    
	/// Font weight for the body
	var bodyWeight: Font.Weight {
		switch self {
		case .default: return .regular
		case .compact: return .regular
		case .large: return .regular
		case .serif: return .regular
		}
	}
}
