//
//  AppConstants.swift
//  TravelBuddy
//
//  Created by Dennis Bär on 24.04.25.
//

import Foundation
import SwiftUI

/// A central location for application-wide constants and configuration values
enum AppConstants {
	// MARK: - Feature Flags
    
	/// Controls whether CloudKit synchronization is enabled
	static let enableCloudSync = true
    
	/// Controls whether analytics are enabled
	static let enableAnalytics = false
    
	/// Controls whether debug logging is enabled
	static let enableDebugLogging = false
    
	// MARK: - UI Constants
    
	/// Standard corner radius for cards and containers
	static let cornerRadius: CGFloat = 16
    
	/// Standard padding for screen margins
	static let screenPadding: CGFloat = 16
    
	/// Spacing between elements in a stack
	static let standardSpacing: CGFloat = 12
    
	/// Standard shadow radius for elevated components
	static let shadowRadius: CGFloat = 8
    
	// MARK: - Animation Constants
    
	/// Standard duration for animations
	static let animationDuration: Double = 0.3
    
	/// Spring animation configuration for lively responses
	static let springAnimation: Animation = .spring(response: 0.4, dampingFraction: 0.7)
    
	// MARK: - Data Defaults
    
	/// Default number of days for a new trip
	static let defaultTripDuration: Int = 7
    
	/// Maximum number of trips allowed for free users
	static let freeUserTripLimit: Int = 3
    
	/// Maximum number of items allowed per trip for free users
	static let freeUserItemLimit: Int = 25
    
	// MARK: - Storage Keys
    
	enum UserDefaultsKeys {
		/// Key for tracking onboarding completion
		static let hasCompletedOnboarding = "hasCompletedOnboarding"
        
		/// Key for storing user premium status
		static let userPremiumStatus = "userPremiumStatus"
        
		/// Key for storing the last time the app was used
		static let lastUsedDate = "lastUsedDate"
	}
    
	// MARK: - CloudKit Container IDs
    
	enum CloudKit {
		/// Container identifier for CloudKit storage
		static let containerId = "iCloud.com.dennisdevlops.TravelBuddy.Trips"
	}
    
	// MARK: - Debugging & Development
    
	/// Controls whether to include sample data in development
	static let includeSampleData = false
    
	/// Controls whether to reset user preferences on launch (dev only)
	static let resetPreferencesOnLaunch = false
}

// MARK: - Color Extensions

extension Color {
	// MARK: - App Theme Colors
    
	/// Primary brand color
	static var primaryColor: Color {
		Color("TripBuddyPrimary")
	}
    
	/// Secondary/accent color
	static var accentColor: Color {
		Color("TripBuddyAccent")
	}
    
	/// Success color for positive feedback
	static var successColor: Color {
		Color("TripBuddySuccess")
	}
    
	/// Alert color for warnings and important notices
	static var alertColor: Color {
		Color("TripBuddyAlert")
	}
    
	/// Background color for the app
	static var backgroundColor: Color {
		Color("TripBuddyBackground")
	}
    
	/// Card background color
	static var cardColor: Color {
		Color("TripBuddyCard")
	}
    
	/// Primary text color
	static var textColor: Color {
		Color("TripBuddyText")
	}
    
	/// Secondary text color for less important information
	static var textSecondaryColor: Color {
		Color("TripBuddyTextSecondary")
	}
}

// MARK: - Convenience Access for Theme Colors

extension View {
	/// Applies the standard card style to a view
	func cardStyle() -> some View {
		self
			.background(Color.cardColor)
			.cornerRadius(AppConstants.cornerRadius)
			.shadow(
				color: Color.textColor.opacity(0.08),
				radius: AppConstants.shadowRadius / 2,
				x: 0,
				y: 2
			)
	}
    
	/// Applies standard screen padding to a view
	func screenPadding() -> some View {
		self.padding(AppConstants.screenPadding)
	}
}
