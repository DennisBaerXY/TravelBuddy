//
//  LocalizationManager.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//

import Combine
import Foundation
import SwiftUI

/// Manages app localization and language settings
class LocalizationManager: ObservableObject {
	// MARK: - Shared Instance
    
	/// Shared singleton instance
	static let shared = LocalizationManager()
    
	// MARK: - Published Properties
    
	/// The current app language
	@Published var currentLanguage: AppLanguage
    
	/// The current locale
	@Published var currentLocale: Locale
    
	// MARK: - Private Properties
    
	/// The defaults key for storing the language preference
	private let languageKey = "app_language"
    
	/// The bundle containing the current language's strings
	private var bundle: Bundle? = nil
    
	// MARK: - Initialization
    
	/// Creates a new localization manager
	private init() {
		// Get the saved language or use the system language
		currentLocale = Locale.current
		if let savedCode = UserDefaults.standard.string(forKey: languageKey),
		   let savedLanguage = AppLanguage(rawValue: savedCode)
		{
			currentLanguage = savedLanguage
		} else {
			// Get the preferred language from the system
			let preferredLanguage = Locale.preferredLanguages.first?.prefix(2) ?? "en"
			currentLanguage = AppLanguage(rawValue: String(preferredLanguage)) ?? .english
		}
		bundle = nil
		// Create the locale for the current language
		
		currentLocale = Locale(identifier: currentLanguage.rawValue)
	
		if currentLanguage == .english || currentLanguage == .system {
			bundle = .main
			return
		}
		
		// Find the bundle for the selected language
		guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj") else {
			bundle = .main
			return
		}
		
		bundle = Bundle(path: path)
	}
    
	// MARK: - Public Methods
    
	/// Sets the app's language
	/// - Parameter language: The language to set
	func setLanguage(_ language: AppLanguage) {
		guard language != currentLanguage else { return }
        
		// Save the language preference
		UserDefaults.standard.set(language.rawValue, forKey: languageKey)
        
		// Update the current language and locale
		currentLanguage = language
		currentLocale = Locale(identifier: language.rawValue)
        
		// Set the active bundle for the new language
		setLanguageBundle()
        
		// Post a notification for language change
		NotificationCenter.default.post(name: .languageDidChange, object: nil)
	}
    
	/// Returns a localized string for the given key
	/// - Parameters:
	///   - key: The localization key
	///   - comment: A comment to help translators (ignored at runtime)
	/// - Returns: The localized string
	func localizedString(_ key: String, comment: String = "") -> String {
		return NSLocalizedString(key, tableName: nil, bundle: bundle ?? .main, value: key, comment: comment)
	}
    
	/// Returns a formatted string with the current locale's number format
	/// - Parameter value: The number to format
	/// - Returns: The formatted string
	func formattedNumber(_ value: Double) -> String {
		let formatter = NumberFormatter()
		formatter.locale = currentLocale
		formatter.numberStyle = .decimal
		return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
	}
    
	/// Returns a formatted currency string with the current locale's currency format
	/// - Parameters:
	///   - value: The amount to format
	///   - currencyCode: The currency code (e.g., "USD") or nil to use the locale's default
	/// - Returns: The formatted currency string
	func formattedCurrency(_ value: Double, currencyCode: String? = nil) -> String {
		let formatter = NumberFormatter()
		formatter.locale = currentLocale
		formatter.numberStyle = .currency
		if let currencyCode = currencyCode {
			formatter.currencyCode = currencyCode
		}
		return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
	}
    
	/// Returns a formatted date string with the current locale's date format
	/// - Parameters:
	///   - date: The date to format
	///   - style: The date style to use
	///   - timeStyle: The time style to use
	/// - Returns: The formatted date string
	func formattedDate(_ date: Date, style: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .none) -> String {
		let formatter = DateFormatter()
		formatter.locale = currentLocale
		formatter.dateStyle = style
		formatter.timeStyle = timeStyle
		return formatter.string(from: date)
	}
    
	/// Returns a formatted date range string with the current locale's format
	/// - Parameters:
	///   - startDate: The start date of the range
	///   - endDate: The end date of the range
	/// - Returns: The formatted date range string
	func formattedDateRange(from startDate: Date, to endDate: Date) -> String {
		let startFormatter = DateFormatter()
		let endFormatter = DateFormatter()
		startFormatter.locale = currentLocale
		endFormatter.locale = currentLocale
        
		// If dates are in the same year, only show the year once
		if Calendar.current.component(.year, from: startDate) == Calendar.current.component(.year, from: endDate) {
			startFormatter.dateFormat = "d MMM"
			endFormatter.dateFormat = "d MMM yyyy"
		} else {
			startFormatter.dateFormat = "d MMM yyyy"
			endFormatter.dateFormat = "d MMM yyyy"
		}
        
		return "\(startFormatter.string(from: startDate)) - \(endFormatter.string(from: endDate))"
	}
    
	// MARK: - Private Methods
    
	/// Sets the active language bundle
	private func setLanguageBundle() {
		// Use the main bundle for the default language
	}
}

// MARK: - App Language

/// Supported app languages
enum AppLanguage: String, CaseIterable, Identifiable {
	case system
	case english = "en"
	case german = "de"
	case spanish = "es"
	case french = "fr"
	case italian = "it"
    
	var id: String { rawValue }
    
	/// The display name of the language
	var displayName: String {
		switch self {
		case .system: return "System Language"
		case .english: return "English"
		case .german: return "Deutsch"
		case .spanish: return "Español"
		case .french: return "Français"
		case .italian: return "Italiano"
		}
	}
    
	/// The flag emoji for the language
	var flag: String {
		switch self {
		case .system: return "🌐"
		case .english: return "🇺🇸"
		case .german: return "🇩🇪"
		case .spanish: return "🇪🇸"
		case .french: return "🇫🇷"
		case .italian: return "🇮🇹"
		}
	}
}

// MARK: - Notification Extension

extension Notification.Name {
	/// Notification posted when the app language changes
	static let languageDidChange = Notification.Name("languageDidChange")
}

// MARK: - String Extension

extension String {
	/// Returns a localized version of the string
	var localized: String {
		return LocalizationManager.shared.localizedString(self)
	}
    
	/// Returns a localized version of the string with format arguments
	/// - Parameter args: Format arguments to insert into the localized string
	/// - Returns: The formatted, localized string
	func localized(with args: CVarArg...) -> String {
		let localizedString = LocalizationManager.shared.localizedString(self)
		return String(format: localizedString, arguments: args)
	}
}

// MARK: - View Extension

extension View {
	/// Applies the current locale to date and number formatters in a view
	/// - Returns: The view with the locale applied
	func withLocale() -> some View {
		environment(\.locale, LocalizationManager.shared.currentLocale)
	}
}

// MARK: - Localized Text View

/// A text view that updates when the language changes
struct LocalizedText: View {
	/// The localization key
	let key: String
    
	/// Format arguments to insert into the localized string
	var args: [CVarArg] = []
    
	/// Text style to apply
	var style: Font.TextStyle?
    
	/// Font weight to apply
	var weight: Font.Weight?
    
	/// Creates a new localized text view
	/// - Parameters:
	///   - key: The localization key
	///   - args: Format arguments to insert into the localized string
	init(_ key: String, args: CVarArg...) {
		self.key = key
		self.args = args
	}
    
	/// The body of the text view
	var body: some View {
		// Force the view to refresh when the language changes
		let _ = NotificationCenter.default.publisher(for: .languageDidChange)
        
		var text = Text(String(format: LocalizationManager.shared.localizedString(key), arguments: args))
        
		if let style = style {
			text = text.font(.system(style))
		}
        
		if let weight = weight {
			text = text.fontWeight(weight)
		}
        
		return text
	}
    
	/// Sets the text style for the view
	/// - Parameter style: The text style to apply
	/// - Returns: A new localized text view with the style applied
	func textStyle(_ style: Font.TextStyle) -> LocalizedText {
		var view = self
		view.style = style
		return view
	}
    
	/// Sets the font weight for the view
	/// - Parameter weight: The font weight to apply
	/// - Returns: A new localized text view with the weight applied
	func fontWeight(_ weight: Font.Weight) -> LocalizedText {
		var view = self
		view.weight = weight
		return view
	}
}
