//
//  ColorSchemePreference.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//


import SwiftUI
import Combine

/// User preference for color scheme (light, dark, or system)
enum ColorSchemePreference: String, CaseIterable {
    case light
    case dark
    case system
    
    /// Display name for the preference
    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
    
    /// Icon name for the preference
    var iconName: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "gear"
        }
    }
}