//
//  ThemeManager.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//


import SwiftUI
import Combine

/// Manages the app's theme including colors, styles, and appearance
class ThemeManager: ObservableObject {
    // MARK: - Shared Instance
    
    /// Shared singleton instance
    static let shared = ThemeManager()
    
    // MARK: - Published Properties
    
    /// The current color theme
    @Published var colorTheme: ColorTheme = .standard
    
    /// The current text style
    @Published var textStyle: TextStyle = .default
    
    /// The current color scheme preference
    @Published var colorSchemePreference: ColorSchemePreference = .system
    
    /// The current appearance, derived from color scheme preference
    @Published var colorScheme: ColorScheme?
    
    // MARK: - Private Properties
    
    /// Subscription to settings changes
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Creates a new theme manager
    init() {
        // Subscribe to the user's dark mode preference
        UserSettingsManager.shared.$prefersDarkMode
            .sink { [weak self] preference in
                if let preference = preference {
                    self?.colorSchemePreference = preference ? .dark : .light
                } else {
                    self?.colorSchemePreference = .system
                }
                self?.updateColorScheme()
            }
            .store(in: &cancellables)
            
        // Set initial color scheme
        updateColorScheme()
    }
    
    // MARK: - Methods
    
    /// Updates the color scheme based on the current preference
    func updateColorScheme() {
        switch colorSchemePreference {
        case .light:
            colorScheme = .light
        case .dark:
            colorScheme = .dark
        case .system:
            colorScheme = nil // Let the system decide
        }
    }
    
    /// Sets the color scheme preference
    /// - Parameter preference: The new color scheme preference
    func setColorSchemePreference(_ preference: ColorSchemePreference) {
        colorSchemePreference = preference
        
        // Update the UserSettingsManager
        switch preference {
        case .light:
            UserSettingsManager.shared.prefersDarkMode = false
        case .dark:
            UserSettingsManager.shared.prefersDarkMode = true
        case .system:
            UserSettingsManager.shared.prefersDarkMode = nil
        }
        
        updateColorScheme()
    }
    
    /// Sets the color theme
    /// - Parameter theme: The new color theme
    func setColorTheme(_ theme: ColorTheme) {
        colorTheme = theme
    }
    
    /// Sets the text style
    /// - Parameter style: The new text style
    func setTextStyle(_ style: TextStyle) {
        textStyle = style
    }
}

// MARK: - Color Scheme Preference

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

// MARK: - Color Theme

/// Available color themes for the app
enum ColorTheme: String, CaseIterable, Identifiable {
    case standard
    case ocean
    case forest
    case sunset
    case monochrome
    
    var id: String { rawValue }
    
    /// Display name for the theme
    var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .ocean: return "Ocean"
        case .forest: return "Forest"
        case .sunset: return "Sunset"
        case .monochrome: return "Monochrome"
        }
    }
    
    // MARK: - Theme Colors
    
    /// Primary color for the theme
    var primary: Color {
        switch self {
        case .standard: return Color("TripBuddyPrimary")
        case .ocean: return Color(red: 0.0, green: 0.5, blue: 0.9)
        case .forest: return Color(red: 0.2, green: 0.6, blue: 0.3)
        case .sunset: return Color(red: 0.9, green: 0.4, blue: 0.2)
        case .monochrome: return Color(red: 0.2, green: 0.2, blue: 0.2)
        }
    }
    
    /// Accent color for the theme
    var accent: Color {
        switch self {
        case .standard: return Color("TripBuddyAccent")
        case .ocean: return Color(red: 0.0, green: 0.8, blue: 0.8)
        case .forest: return Color(red: 0.8, green: 0.9, blue: 0.3)
        case .sunset: return Color(red: 1.0, green: 0.8, blue: 0.0)
        case .monochrome: return Color(red: 0.6, green: 0.6, blue: 0.6)
        }
    }
    
    /// Success color for the theme
    var success: Color {
        switch self {
        case .standard: return Color("TripBuddySuccess")
        case .ocean: return Color(red: 0.2, green: 0.8, blue: 0.5)
        case .forest: return Color(red: 0.4, green: 0.8, blue: 0.4)
        case .sunset: return Color(red: 0.6, green: 0.9, blue: 0.4)
        case .monochrome: return Color(red: 0.5, green: 0.5, blue: 0.5)
        }
    }
    
    /// Alert color for the theme
    var alert: Color {
        switch self {
        case .standard: return Color("TripBuddyAlert")
        case .ocean: return Color(red: 1.0, green: 0.4, blue: 0.4)
        case .forest: return Color(red: 0.9, green: 0.5, blue: 0.2)
        case .sunset: return Color(red: 0.8, green: 0.2, blue: 0.3)
        case .monochrome: return Color(red: 0.8, green: 0.2, blue: 0.2)
        }
    }
    
    /// Background color for the theme
    var background: Color {
        switch self {
        case .standard: return Color("TripBuddyBackground")
        case .ocean: return Color(red: 0.95, green: 0.98, blue: 1.0)
        case .forest: return Color(red: 0.95, green: 0.98, blue: 0.95)
        case .sunset: return Color(red: 0.98, green: 0.95, blue: 0.95)
        case .monochrome: return Color(red: 0.95, green: 0.95, blue: 0.95)
        }
    }
    
    /// Card background color for the theme
    var card: Color {
        switch self {
        case .standard: return Color("TripBuddyCard")
        case .ocean: return Color.white
        case .forest: return Color.white
        case .sunset: return Color.white
        case .monochrome: return Color.white
        }
    }
    
    /// Text color for the theme
    var text: Color {
        switch self {
        case .standard: return Color("TripBuddyText")
        case .ocean: return Color(red: 0.1, green: 0.1, blue: 0.3)
        case .forest: return Color(red: 0.1, green: 0.2, blue: 0.1)
        case .sunset: return Color(red: 0.3, green: 0.1, blue: 0.1)
        case .monochrome: return Color(red: 0.1, green: 0.1, blue: 0.1)
        }
    }
    
    /// Secondary text color for the theme
    var textSecondary: Color {
        switch self {
        case .standard: return Color("TripBuddyTextSecondary")
        case .ocean: return Color(red: 0.3, green: 0.3, blue: 0.5)
        case .forest: return Color(red: 0.3, green: 0.4, blue: 0.3)
        case .sunset: return Color(red: 0.5, green: 0.3, blue: 0.3)
        case .monochrome: return Color(red: 0.4, green: 0.4, blue: 0.4)
        }
    }
    
    // MARK: - Dark Mode Colors
    
    /// Primary color for dark mode
    var primaryDark: Color {
        switch self {
        case .standard: return Color("TripBuddyPrimary")
        case .ocean: return Color(red: 0.1, green: 0.6, blue: 1.0)
        case .forest: return Color(red: 0.3, green: 0.7, blue: 0.4)
        case .sunset: return Color(red: 1.0, green: 0.5, blue: 0.3)
        case .monochrome: return Color(red: 0.8, green: 0.8, blue: 0.8)
        }
    }
    
    /// Background color for dark mode
    var backgroundDark: Color {
        switch self {
        case .standard: return Color("TripBuddyBackground")
        case .ocean: return Color(red: 0.05, green: 0.1, blue: 0.15)
        case .forest: return Color(red: 0.05, green: 0.1, blue: 0.05)
        case .sunset: return Color(red: 0.15, green: 0.05, blue: 0.05)
        case .monochrome: return Color(red: 0.1, green: 0.1, blue: 0.1)
        }
    }
    
    /// Card background color for dark mode
    var cardDark: Color {
        switch self {
        case .standard: return Color("TripBuddyCard")
        case .ocean: return Color(red: 0.1, green: 0.15, blue: 0.2)
        case .forest: return Color(red: 0.1, green: 0.15, blue: 0.1)
        case .sunset: return Color(red: 0.2, green: 0.1, blue: 0.1)
        case .monochrome: return Color(red: 0.15, green: 0.15, blue: 0.15)
        }
    }
    
    /// Text color for dark mode
    var textDark: Color {
        switch self {
        case .standard: return Color("TripBuddyText")
        case .ocean: return Color(red: 0.9, green: 0.95, blue: 1.0)
        case .forest: return Color(red: 0.9, green: 1.0, blue: 0.9)
        case .sunset: return Color(red: 1.0, green: 0.9, blue: 0.9)
        case .monochrome: return Color(red: 0.9, green: 0.9, blue: 0.9)
        }
    }
    
    /// Secondary text color for dark mode
    var textSecondaryDark: Color {
        switch self {
        case .standard: return Color("TripBuddyTextSecondary")
        case .ocean: return Color(red: 0.7, green: 0.75, blue: 0.8)
        case .forest: return Color(red: 0.7, green: 0.8, blue: 0.7)
        case .sunset: return Color(red: 0.8, green: 0.7, blue: 0.7)
        case .monochrome: return Color(red: 0.7, green: 0.7, blue: 0.7)
        }
    }
}

// MARK: - Text Style

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

// MARK: - View Extensions

/// Extension for applying themes to views
extension View {
    /// Applies the current theme to a view
    /// - Returns: The view with the theme applied
    func themed() -> some View {
        modifier(ThemeModifier())
    }
    
    /// Applies a specific theme to a view
    /// - Parameter theme: The theme to apply
    /// - Returns: The view with the specified theme applied
    func themed(_ theme: ColorTheme) -> some View {
        modifier(CustomThemeModifier(theme: theme))
    }
}

// MARK: - Theme Modifiers

/// Modifier for applying the current theme
struct ThemeModifier: ViewModifier {
    @ObservedObject private var themeManager = ThemeManager.shared
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(themeManager.colorScheme)
    }
}

/// Modifier for applying a specific theme
struct CustomThemeModifier: ViewModifier {
    let theme: ColorTheme
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
    }
}